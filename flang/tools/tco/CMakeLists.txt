get_property(dialect_libs GLOBAL PROPERTY MLIR_DIALECT_LIBS)

set(LIBS
  FIRDialect
  FIRSupport
  ${dialect_libs}
  MLIRIR
  MLIRLLVMIR
  MLIRPass
  MLIRStandardToLLVM
  MLIRTransforms
  MLIRAffineToStandard
  MLIRAnalysis
  MLIRSCFToStandard
  MLIREDSC
  MLIRParser
  MLIRStandardToLLVM
  MLIRSupport
  MLIRVectorToLLVM
)

add_flang_tool(tco tco.cpp)
target_link_libraries(tco PRIVATE ${LIBS})
