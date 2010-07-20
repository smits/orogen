# What does the task library needs ?
#  - it needs to be able to include the <typekit_name>TypekitTypes.hpp files for
#    each used typekit. It does not need to link the library, though, because the
#    typekit itself is hidden from the actual task contexts.
#  - it needs to have access to the dependent task libraries and libraries. This
#    is true for both the headers and the link interface itself.
#
# What this file does is set up the following variables:
#  component_TASKLIB_NAME
#     the name of the library (test-tasks-gnulinux for instance)
#
#  <PROJECT>_TASKLIB_SOURCES
#     the .cpp files that define the task context classes, including the
#     autogenerated parts.
#
#  <PROJECT>_TASKLIB_SOURCES
#     the .hpp files that declare the task context classes, including the
#     autogenerated parts.
#
#  <PROJECT>_TASKLIB_DEPENDENT_LIBRARIES
#     the list of libraries to which the task library should be linked.
#
# These variables are used in tasks/CMakeLists.txt to actually build the shared
# object.

include_directories(${PROJECT_SOURCE_DIR}/<%= Generation::AUTOMATIC_AREA_NAME %>)

<% if component.typekit %>
include_directories(${PROJECT_SOURCE_DIR}/<%= Generation::AUTOMATIC_AREA_NAME %>/typekit)
list(APPEND <%= component.name.upcase %>_TASKLIB_DEPENDENT_LIBRARIES 
    <%= component.name %>-typekit-${OROCOS_TARGET})
<% end %>

<%= dependencies = component.tasklib_dependencies
    Generation.cmake_pkgconfig_require(dependencies) %>
<% dependencies.each do |dep_def|
   next if !dep_def.link %>
list(APPEND <%= component.name.upcase %>_TASKLIB_DEPENDENT_LIBRARIES ${<%= dep_def.var_name %>_LIBRARIES})
<% if dep_def.var_name =~ /TASKLIB/ %>
list(APPEND <%= component.name.upcase %>_TASKLIB_INTERFACE_LIBRARIES ${<%= dep_def.var_name %>_TASKLIB_LIBRARIES})
<% end %>
<% end %>

CONFIGURE_FILE(${PROJECT_SOURCE_DIR}/<%= Generation::AUTOMATIC_AREA_NAME %>/tasks/<%= component.name %>-tasks.pc.in
    ${CMAKE_CURRENT_BINARY_DIR}/<%= component.name %>-tasks-${OROCOS_TARGET}.pc @ONLY)
INSTALL(FILES ${CMAKE_CURRENT_BINARY_DIR}/<%= component.name %>-tasks-${OROCOS_TARGET}.pc
    DESTINATION lib/pkgconfig)

<% 
   include_files = []
   task_files = []
   component.self_tasks.each do |task| 
     if !task_files.empty?
	 task_files << "\n    "
     end
     task_files << "${CMAKE_SOURCE_DIR}/#{Generation::AUTOMATIC_AREA_NAME}/tasks/#{task.basename}Base.cpp"
     task_files << "#{task.basename}.cpp"
     include_files << "${CMAKE_SOURCE_DIR}/#{Generation::AUTOMATIC_AREA_NAME}/tasks/#{task.basename}Base.hpp"
     include_files << "#{task.basename}.hpp"
   end
%>

set(<%= component.name.upcase %>_TASKLIB_NAME <%= component.name %>-tasks-${OROCOS_TARGET})
set(<%= component.name.upcase %>_TASKLIB_SOURCES <%= task_files.sort.join(" ") %>)
set(<%= component.name.upcase %>_TASKLIB_HEADERS <%= include_files.sort.join(" ") %>)
include_directories(${OrocosRTT_INCLUDE_DIRS})
link_directories(${OrocosRTT_LIBRARY_DIRS})
add_definitions(${OrocosRTT_CFLAGS_OTHER})

