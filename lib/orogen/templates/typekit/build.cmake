# Generated from orogen/lib/orogen/templates/typekit/build.cmake

cmake_minimum_required(VERSION 2.8.3)

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_CURRENT_LIST_DIR}/config")
include(OrogenPkgCheckModules)

execute_process(COMMAND cmake -E create_symlink
    ${CMAKE_CURRENT_LIST_DIR} ${CMAKE_CURRENT_LIST_DIR}/<%= typekit.name %>)

include_directories(BEFORE ${CMAKE_CURRENT_LIST_DIR})
include_directories(BEFORE ${CMAKE_CURRENT_LIST_DIR}/types)

<% if typekit.has_opaques_with_templates? %>
include_directories(BEFORE ${CMAKE_SOURCE_DIR}/typekit)
<% end %>

# Now set up the dependencies
<%= typekit_deps = typekit.dependencies
    Generation.cmake_pkgconfig_require(typekit_deps) %>
set(PKG_CFLAGS ${OrocosRTT_CFLAGS})
<%  typekit_deps.each do |dep_def|
        if dep_def.in_context?('core', 'include') %>
set(PKG_CFLAGS ${PKG_CFLAGS} ${<%= dep_def.var_name %>_CFLAGS})
        <% end %>
    <% end %>
string(REPLACE ";" "\" \"" PKG_CFLAGS "\"${PKG_CFLAGS}\"")

# Generate the base typekit shared library
set(libname <%= typekit.name %>-typekit)
orocos_typekit(${libname}
    <%= relatives = []
        implementation_files.each do |file|
        relatives << typekit.relative_path(file)
        end
        relatives.sort.map { |filepath| '${CMAKE_CURRENT_LIST_DIR}/'+filepath }.join("\n    ") %>
    ${TYPEKIT_ADDITIONAL_SOURCES}
    ${TOOLKIT_ADDITIONAL_SOURCES})

<%= Generation.cmake_pkgconfig_link_noncorba('${libname}', typekit_deps) %>
target_link_libraries(${libname} ${TYPEKIT_ADDITIONAL_LIBRARIES} ${TOOLKIT_ADDITIONAL_LIBRARIES})
target_link_libraries(${libname} LINK_INTERFACE_LIBRARIES)
set_target_properties(${libname} PROPERTIES INTERFACE_LINK_LIBRARIES "")
set(PKG_CONFIG_FILE ${CMAKE_CURRENT_LIST_DIR}/<%= typekit.name %>-typekit-${OROCOS_TARGET}.pc)
configure_file(${CMAKE_CURRENT_LIST_DIR}/<%= typekit.name %>-typekit.pc.in ${PKG_CONFIG_FILE} @ONLY)

install(FILES
    ${CMAKE_CURRENT_LIST_DIR}/Types.hpp
    <% if typekit.has_opaques_with_templates? %>
    ${CMAKE_CURRENT_LIST_DIR}/Opaques.hpp
    <% end %>
    DESTINATION include/orocos/<%= typekit.name %>/typekit)
install(FILES
    <%= relatives = []
        public_header_files.each do |file|
        relatives << typekit.relative_path(file)
    end
    relatives.sort.map { |filepath| '${CMAKE_CURRENT_LIST_DIR}/'+filepath }.join("\n    ") %>
    DESTINATION include/orocos/<%= typekit.name %>/typekit)
<% typekit.local_headers(false).each do |path, dest_path| %>

MESSAGE("gen=${CMAKE_CURRENT_LIST_DIR}")
MESSAGE("base=<%= (Pathname.new( typekit.base_dir ))%>")
MESSAGE("auto=<%= (Pathname.new( typekit.automatic_dir ))%>")
MESSAGE("path=<%= (path)%> dest_path=<%= (dest_path) %>")
install(FILES ${CMAKE_CURRENT_LIST_DIR}/types/<%= (path) %>
    DESTINATION include/orocos/<%= typekit.name %>/types/<%= typekit.name %>/<%= File.dirname(dest_path) %>)
<% end %>

install(FILES ${PKG_CONFIG_FILE}
    DESTINATION lib/pkgconfig)

install(FILES ${CMAKE_CURRENT_LIST_DIR}/<%= typekit.name %>.tlb
    ${CMAKE_CURRENT_LIST_DIR}/<%= typekit.name %>.typelist
    DESTINATION share/orogen)

<% typekit.each_plugin do |plg|
    if plg.separate_cmake? %>
    include(${CMAKE_CURRENT_LIST_DIR}/transports/<%= plg.name %>/build.cmake)
    <% end
end %>

# Force the user to regenerate its typekit if the inputs changed
set(TK_STAMP "${CMAKE_CURRENT_LIST_DIR}/stamp")
add_custom_command(
    OUTPUT "${TK_STAMP}"
    DEPENDS <%= loads = []
        typekit.loads.each do |file| 
	    loads << file
        end
        loads.join(" ") %> <%= extloads = []
        typekit.external_loads.each do |file| 
	    extloads << file
        end
        extloads.join(" ") %>
    COMMENT "Typekit input changed. Run make <%= typekit.name %>-regen in your build directory first"
    COMMAND /bin/false)
add_custom_target(<%= typekit.name %>-check-typekit-uptodate ALL DEPENDS "${TK_STAMP}")
add_dependencies(${libname} <%= typekit.name %>-check-typekit-uptodate)
