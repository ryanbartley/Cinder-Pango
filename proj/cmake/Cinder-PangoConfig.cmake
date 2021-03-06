if( NOT TARGET Cinder-Pango )
	
  if( NOT EXISTS ${CINDER_PATH} )
    get_filename_component( CINDER_PATH "${CMAKE_CURRENT_LIST_DIR}/../../../.." ABSOLUTE )
  endif()

  get_filename_component( BLOCK_PATH "${CMAKE_CURRENT_LIST_DIR}/../.." ABSOLUTE )

	if( NOT TARGET cinder )
		include( "${CINDER_PATH}/proj/cmake/configure.cmake" )
		find_package( cinder REQUIRED PATHS
			"${CINDER_PATH}/${CINDER_LIB_DIRECTORY}"
			"$ENV{CINDER_PATH}/${CINDER_LIB_DIRECTORY}" )
	endif()
		
	string( TOLOWER "${CINDER_TARGET}" CINDER_TARGET_LOWER )
	
  get_filename_component( PANGO_LIBS_PATH "${BLOCK_PATH}/lib/${CINDER_TARGET_LOWER}" ABSOLUTE )

	if( "linux" STREQUAL ${CINDER_TARGET_LOWER} )
		set( Cinder-Pango_LIBRARIES 
					${PANGO_LIBS_PATH}/libpangocairo-1.0.a
					${PANGO_LIBS_PATH}/libpangoft2-1.0.a
					${PANGO_LIBS_PATH}/libpangoxft-1.0.a
					${PANGO_LIBS_PATH}/libpango-1.0.a
					${PANGO_LIBS_PATH}/libharfbuzz-icu.a
					${PANGO_LIBS_PATH}/libharfbuzz-gobject.a
					${PANGO_LIBS_PATH}/libharfbuzz.a
					${PANGO_LIBS_PATH}/libcairo.a
					${PANGO_LIBS_PATH}/libpixman-1.a
					${PANGO_LIBS_PATH}/libpng16.a
					${PANGO_LIBS_PATH}/libglib-2.0.a
					${PANGO_LIBS_PATH}/libgio-2.0.a
					${PANGO_LIBS_PATH}/libgobject-2.0.a
					${PANGO_LIBS_PATH}/libgmodule-2.0.a
					${PANGO_LIBS_PATH}/libgthread-2.0.a
					-lfontconfig
					${PANGO_LIBS_PATH}/libasprintf.a
					${PANGO_LIBS_PATH}/libgettextpo.a
					${PANGO_LIBS_PATH}/libffi.a
					-lpcre
					-lexpat
					"${CINDER_PATH}/${CINDER_LIB_DIRECTORY}/libcinder.a"
			)
	elseif( "macosx" STREQUAL ${CINDER_TARGET_LOWER} )
		set( Cinder-Pango_LIBRARIES 
					${PANGO_LIBS_PATH}/libpangocairo-1.0.a
					${PANGO_LIBS_PATH}/libpangoft2-1.0.a
					${PANGO_LIBS_PATH}/libpango-1.0.a
					${PANGO_LIBS_PATH}/libharfbuzz-gobject.a
					${PANGO_LIBS_PATH}/libharfbuzz.a
					${PANGO_LIBS_PATH}/libcairo.a
					${PANGO_LIBS_PATH}/libpixman-1.a
					${PANGO_LIBS_PATH}/libpng16.a
					${PANGO_LIBS_PATH}/libglib-2.0.a
					${PANGO_LIBS_PATH}/libgio-2.0.a
					${PANGO_LIBS_PATH}/libgobject-2.0.a
					${PANGO_LIBS_PATH}/libgmodule-2.0.a
					${PANGO_LIBS_PATH}/libgthread-2.0.a
					${PANGO_LIBS_PATH}/libfontconfig.a
					${PANGO_LIBS_PATH}/libasprintf.a
					${PANGO_LIBS_PATH}/libgettextpo.a
					${PANGO_LIBS_PATH}/libintl.a
					${PANGO_LIBS_PATH}/libffi.a
					-lpcre
					-liconv
					-lexpat
					"${CINDER_PATH}/${CINDER_LIB_DIRECTORY}/libcinder.a"
			)
	endif()

  get_filename_component( PANGO_INCLUDE_PATH "${BLOCK_PATH}/include/${CINDER_TARGET_LOWER}" ABSOLUTE )
  get_filename_component( HARFBUZZ_INCLUDE_PATH "${BLOCK_PATH}/../Cinder-Harfbuzz/include_p/${CINDER_TARGET_LOWER}" ABSOLUTE )
  set( Cinder-Pango_INCLUDES 
        ${PANGO_INCLUDE_PATH}/pango-1.0 
        ${PANGO_INCLUDE_PATH}/glib-2.0
        ${PANGO_INCLUDE_PATH}/harfbuzz
        ${PANGO_INCLUDE_PATH}/cairo  
        ${PANGO_INCLUDE_PATH}
        ${CINDER_PATH}/include/freetype )

endif()
