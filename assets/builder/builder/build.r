library(remotes)

args = commandArgs(trailingOnly = TRUE)
pkgs = tolower(args[1])
source("builder/ENV_VARS")

if (lib == "") {
  lib = .libPaths()[1]
}


d = dir("src", full.names=TRUE)

qprint = function(msg)
{
  if (quiet)
    cat(msg)
}

pkg_tar_name = function(pkg) d[grep(d, pattern=pkg)]

build_package = function(pkg, configure.args=NULL, lib=lib)
{
  qprint(paste0("building ", pkg, "..."))
  ret = remotes::install_local(pkg_tar_name(pkg), configure.args=configure.args, lib=lib, quiet=quiet)
  
  if (!isTRUE(ret))
    stop("FAILED, exiting build", call.=FALSE)
  else
    qprint("ok!\n")
  
  ret
}

build_packages = function(PACKAGES)
{
  if (length(PACKAGES) == 1 && PACKAGES == "")
    invisible(TRUE)
  
  PACKAGES = strsplit(PACKAGES, split=" ")[[1]]
  ret = lapply(PACKAGES, function(pkg) build_package(pkg))
  invisible(TRUE)
}

set_config_args = function(...)
{
  args = unlist(list(...))
  for (i in 1:length(args))
  {
    if (args[i] != "")
    {
      name = sub(names(args)[i], pattern=".", replacement="-", fixed=TRUE)
      args[i] = paste0("--with-", name, "=", args[i])
    }
  }
  
  if (any(args != ""))
    paste(args, collapse=" ")
  else
    NULL
}

pbd_builder = function(pkgs)
{
  if (pkgs == "mpi")
  {
    qprint("### Building MPI packages:\n")
    
    mpi.configure.args = set_config_args(mpi.include=mpi.include, mpi.libpath=mpi.libpath, mpi.type=mpi.type)
    build_package("pbdMPI", configure.args=mpi.configure.args)
    
    PACKAGES = "pbdSLAP pbdBASE pbdDMAT pbdDEMO pbdIO pbdML pmclust kazaam tasktools"
  }
  else if (pkgs == "prof")
  {
    qprint("### Building PROF packages:\n")
    
    if (prof.lib == "")
      prof.lib = lib
    
    prof.configure.args = set_config_args(mpiP=mipP)
    build_package("pbdPROF", configure.args=prof.configure.args)
    build_package("pbdMPI", configure.args="--enable-pbdPROF")
    
    papi.configure.args = set_config_args(papi.home=papi.home)
    build_package("pbdPAPI", configure.args=papi.configure.args)
    
    PACKAGES = "hpcvis"
    
  }
  else if (pkgs == "comm")
  {
    qprint("### Building COMM packages:\n")
    PACKAGES = "pbdZMQ remoter pbdCS"
  }
  else if (pkgs == "io")
  {
    qprint("### Building I/O packages:\n")
    
    nc.configure.args = set_config_args(nc.config=nc.config)
    build_package("pbdNCDF4", configure.args=nc.configure.args)
    
    adios.configure.args = set_config_args(adios.home=adios.home)
    build_package("pbdADIOS", configure.args=adios.configure.args)
  }
  else
    stop("invalid argument to build script")
  
  
  build_packages(PACKAGES)
  cat("\n")
}



pbd_builder(pkgs)
