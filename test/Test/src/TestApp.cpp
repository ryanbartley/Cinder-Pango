#include "cinder/app/App.h"
#include "cinder/app/RendererGl.h"
#include "cinder/gl/gl.h"

#include <stdio.h>
#include <stdlib.h>
#include <cairo.h>
#include <freetype/ftbitmap.h>
#include <pango/pangocairo.h>
#include <pango/pangoft2.h>

#define USE_FREETYPE 1
#define USE_RGBA 0

using namespace ci;
using namespace ci::app;
using namespace std;

class TestApp : public App {
  public:
	void setup() override;
	void mouseDown( MouseEvent event ) override;
	void update() override;
	void draw() override;
};

void TestApp::setup()
{
	auto dir = getAssetDirectories()[0] / "fonts";
	for( auto filePath = fs::directory_iterator( dir ); filePath != fs::directory_iterator(); ++filePath ) {
		const FcChar8 * file = (const FcChar8 *)filePath->path().c_str();
		FcBool fontAddStatus = FcConfigAppFontAddFile(FcConfigGetCurrent(), file);
		if( ! fontAddStatus )
			cout << "Problem adding: " << file << endl;
	}
	
	
	cairo_surface_t* surf = nullptr;
	cairo_t* cr = nullptr;
	cairo_status_t status;
	cairo_font_options_t* font_options = nullptr;
	PangoContext* context = nullptr;
	PangoLayout* layout = nullptr;
	PangoFontDescription* font_desc = nullptr;
	PangoFontMap* font_map = nullptr;
	
	uvec2 size(640, 480);
 
	/* ------------------------------------------------------------ */
	/*                   I N I T I A L I Z E                        */
	/* ------------------------------------------------------------ */
 
	surf = cairo_image_surface_create( CAIRO_FORMAT_ARGB32, size.x, size.y );
 
	if (CAIRO_STATUS_SUCCESS != cairo_surface_status(surf)) {
		printf("+ error: couldn't create the surface.\n");
		exit(EXIT_FAILURE);
	}
 
	/* create our cairo context object that tracks state. */
	cr = cairo_create(surf);
	if (CAIRO_STATUS_NO_MEMORY == cairo_status(cr)) {
		printf("+ error: out of memory, cannot create cairo_t*\n");
		exit(EXIT_FAILURE);
	}
 
	/* ------------------------------------------------------------ */
	/*               D R A W   I N T O  C A N V A S                 */
	/* ------------------------------------------------------------ */
 
	font_map = pango_cairo_font_map_get_default();
	if (nullptr == font_map) {
		printf("+ error: cannot create the pango font map.\n");
		exit(EXIT_FAILURE);
	}
 
	context = pango_font_map_create_context( font_map );
	if (nullptr == context) {
		printf("+ error: cannot create pango font context.\n");
		exit(EXIT_FAILURE);
	}
 
	/* create layout object. */
	layout = pango_layout_new( context );
	if (nullptr == layout) {
		printf("+ error: cannot create the pango layout.\n");
		exit(EXIT_FAILURE);
	}
	
	font_options = cairo_font_options_create();
	if (nullptr == font_options) {
		printf("+ error: cannot create the font options.\n");
		exit(EXIT_FAILURE);
	}
	
	cairo_font_options_set_antialias( font_options, cairo_antialias_t::CAIRO_ANTIALIAS_GRAY );
	cairo_font_options_set_hint_style( font_options, CAIRO_HINT_STYLE_FULL );
	cairo_font_options_set_hint_metrics( font_options, CAIRO_HINT_METRICS_ON );
	pango_cairo_context_set_font_options( context, font_options );
	
	/* create the font description @todo the reference does not tell how/when to free this */
	font_desc = pango_font_description_from_string("Linux Libertine 35");
	pango_layout_set_font_description(layout, font_desc);
	pango_font_map_load_font(font_map, context, font_desc);
	pango_font_description_free(font_desc);
 
	/* set the width around which pango will wrap */
	pango_layout_set_width(layout, 300 * PANGO_SCALE);
 
	/* write using the markup feature */
	const gchar* text = ""
	"<span foreground=\"blue\" font_family=\"Linux Libertine\">"
	"<b>bold </b>"
	"<u> is </u>"
	"<i> nice </i></span>\n"
	"<span foreground=\"black\"><tt>hello</tt>\n"
	"<span font_family=\"sans\" font_stretch=\"ultracondensed\" letter_spacing=\"500\" font_weight=\"light\">SANS</span>\n</span>"
	"<span foreground=\"#FF0000\">colored</span>";
 
	pango_layout_set_markup(layout, text, -1);
	
	cairo_save( cr );
	cairo_set_operator( cr, CAIRO_OPERATOR_CLEAR );
	cairo_paint( cr );
	cairo_restore( cr );
	cairo_set_source_rgba( cr, 1, 1, 1, 1 );
	
	/* render */
	pango_cairo_update_layout(cr, layout);
	pango_cairo_show_layout( cr, layout );
 
	/* ------------------------------------------------------------ */
	/*               O U T P U T  A N D  C L E A N U P              */
	/* ------------------------------------------------------------ */
 
	/* write to png */
	status = cairo_surface_write_to_png(surf, (getAssetDirectories()[0] / "helloworld.png").c_str() );
	if (CAIRO_STATUS_SUCCESS != status) {
		printf("+ error: couldn't write to png\n");
		exit(EXIT_FAILURE);
	}
 
	cairo_surface_destroy(surf);
	cairo_destroy(cr);
 
	g_object_unref(layout);
	g_object_unref(font_map);
	g_object_unref(context);
}

void TestApp::mouseDown( MouseEvent event )
{
}

void TestApp::update()
{
}

void TestApp::draw()
{
	gl::clear( Color( 0, 0, 0 ) );
}

CINDER_APP( TestApp, RendererGl )
