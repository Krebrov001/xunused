CC  := clang
CXX := clang++

# Redefine make link target to use CXX instead of CC as linker
LINK.o = $(CXX) $(LDFLAGS) $(TARGET_ARCH)

# Configuration flags for the LLVM libraries.
BINDIR           := $(realpath $(dir $(shell which llvm-config)))
LLVMCONFIG       := $(BINDIR)/llvm-config
LLVMCOMPONENTS   := profiledata bitreader option mcparser
CXXFLAGS         := $(shell $(LLVMCONFIG) --cxxflags) -std=c++14 -fcxx-exceptions -g -Wall

# If object or library AA needs a symbol from library BB, then AA should come before library BB in the command-
# line invocation of the linker.
# The result is a reverse topological sort.
# Libraries that are dependents come before their dependencies.
LDLIBS := \
	-lclangStaticAnalyzerFrontend\
	-lclangStaticAnalyzerCheckers\
	-lclangStaticAnalyzerCore\
	-lclangCrossTU\
    -lclangIndex\
	-lclangTooling\
	-lclangFormat\
	-lclangToolingInclusions\
	-lclangToolingCore\
	-lclangFrontend\
	-lclangSerialization\
	-lclangParse\
	-lclangSema\
    -lclangAnalysis\
    -lclangEdit\
    -lclangASTMatchers\
    -lclangAST\
    -lclangRewrite\
    -lclangLex\
    -lclangDriver\
	-lclangBasic\
	$(shell $(LLVMCONFIG) --libs $(LLVMCOMPONENTS))\
	$(shell $(LLVMCONFIG) --system-libs $(LLVMCOMPONENTS))

# Names of files used in this project.
EXECUTABLE := xunused
CXX_FILES  := main.cpp

O_FILES    := $(CXX_FILES:cpp=o)

# What is the purpose of .PHONY in a makefile?
# https://stackoverflow.com/q/2145590/5500589

# Build executables
.PHONY: all
all: $(EXECUTABLE)

# Install executables into same directory as llvm-config, by command
.PHONY: install
install: $(EXECUTABLE)
	sudo cp $(EXECUTABLE) $(BINDIR)

# Install executables into same directory as llvm-config, on demand
$(addprefix $(BINDIR)/,$(EXECUTABLE)): $(EXECUTABLE)
	sudo cp $(EXECUTABLE) $(BINDIR)

# File dependencies
$(EXECUTABLE): $(O_FILES)
	$(CXX)   $(O_FILES) -lclangStaticAnalyzerFrontend -lclangStaticAnalyzerCheckers -lclangStaticAnalyzerCore -lclangCrossTU -lclangIndex -lclangTooling -lclangFormat -lclangToolingInclusions -lclangToolingCore -lclangFrontend -lclangSerialization -lclangParse -lclangSema -lclangAnalysis -lclangEdit -lclangASTMatchers -lclangAST -lclangRewrite -lclangLex -lclangDriver -lclangBasic -lLLVMMCParser -lLLVMMC -lLLVMDebugInfoCodeView -lLLVMDebugInfoMSF -lLLVMOption -lLLVMBitReader -lLLVMBitstreamReader -lLLVMProfileData -lLLVMCore -lLLVMRemarks -lLLVMBinaryFormat -lLLVMSupport -lLLVMDemangle -lrt -ldl -ltinfo -lpthread -lm -o $(EXECUTABLE)

main.o: main.cpp

.PHONY: clean
clean:
	rm -f $(EXECUTABLE) $(O_FILES)
	sudo rm -f $(addprefix $(BINDIR)/,$(EXECUTABLE))

# Temp stuff
.PHONY: show
show:
	echo $(BINDIR)
	echo $(LLVMCONFIG)
	echo $(LLVMCOMPONENTS)
	echo $(CXXFLAGS)
	echo $(LDFLAGS)
	echo $(TARGET_ARCH)
