if( NOT TARGET Cinder-Pango )
	
	get_filename_component( CINDER_PATH "${CMAKE_CURRENT_LIST_DIR}/../../../.." ABSOLUTE )
  get_filename_component( BLOCK_PATH "${CMAKE_CURRENT_LIST_DIR}/../.." ABSOLUTE )

	if( NOT TARGET cinder )
		include( "${CINDER_PATH}/proj/cmake/configure.cmake" )
		find_package( cinder REQUIRED PATHS
			"${CINDER_PATH}/${CINDER_LIB_DIRECTORY}"
			"$ENV{CINDER_PATH}/${CINDER_LIB_DIRECTORY}" )
	endif()
		
	string( TOLOWER "${CINDER_TARGET}" CINDER_TARGET_LOWER )
	
  get_filename_component( PANGO_LIBS_PATH "${BLOCK_PATH}/lib/${CINDER_TARGET_LOWER}" ABSOLUTE )
  get_filename_component( HARFBUZZ_LIBS_PATH "${BLOCK_PATH}/../Cinder-Harfbuzz/lib_p/${CINDER_TARGET_LOWER}" ABSOLUTE )
  set( Cinder-Pango_LIBRARIES 
        ${PANGO_LIBS_PATH}/libpangocairo.a
        ${PANGO_LIBS_PATH}/libpangooft2.a
        ${PANGO_LIBS_PATH}/libpango-1.0.a
        ${HARFBUZZ_LIBS_PATH}/libharfbuzz-gobject.a
        ${HARFBUZZ_LIBS_PATH}/libharfbuzz.a
        ${PANGO_LIBS_PATH}/libglib-2.0.a
        ${PANGO_LIBS_PATH}/libgio-2.0.a
        ${PANGO_LIBS_PATH}/libgobject-2.0.a
        ${PANGO_LIBS_PATH}/libgmodule-2.0.a
        ${PANGO_LIBS_PATH}/libgthread-2.0.a
    )
  get_filename_component( PANGO_INCLUDE_PATH "${BLOCK_PATH}/include/${CINDER_TARGET_LOWER}" ABSOLUTE )
  get_filename_component( HARFBUZZ_INCLUDE_PATH "${BLOCK_PATH}/../Cinder-Harfbuzz/include_p/${CINDER_TARGET_LOWER}" ABSOLUTE )
  set( Cinder-Pango_INCLUDES 
        ${PANGO_INCLUDE_PATH}/pango-1.0 
        ${PANGO_INCLUDE_PATH}/glib-2.0
        ${HARFBUZZ_INCLUDE_PATH}/harfbuzz  
        ${CINDER_PATH}/include/freetype )

endif()
