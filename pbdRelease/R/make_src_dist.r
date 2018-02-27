setup_release = function(root_path, version, clobber)
{
  release_path = paste0(root_path, "/releases/pbdR_", version)
  if (is.null(clobber))
  {
    cat(paste0("\n\nWARNING: release path already exists for version ", version, ". Did you forget to change 'version'? Type 'OK' to continue, anything else to quit.\n"))
    response = readLines(file("stdin"), n=1)
    if (response == "OK")
      clobber = TRUE
    else
      stop("release directory already exists")
  }
  
  if (isTRUE(clobber))
    unlink(release_path, recursive=TRUE)
  
  if (!file.exists(release_path))
  {
    dir.create(release_path, recursive=TRUE)
    dir.create(paste0(release_path, "/src"))
    dir.create(paste0(release_path, "/licenses"))
    dir.create(paste0(release_path, "/builder"))
    dir.create(paste0(release_path, "/docs"))
  }
  
  release_path
}



build_docs = function(root_path, release_path)
{
  src_path = paste0(release_path, "/src")
  setwd(src_path)
  pkgs = dir()
  
  for (pkg in pkgs)
  {
    pkg.name = strsplit(pkg, split="_")[[1]][1]
    system(paste0("tar zxf ", pkg, " ", pkg.name, "/man"))
    tools::Rcmd(paste0("Rd2pdf ", pkg.name, " --no-preview -o ", pkg.name, ".pdf"))
  }
  
  system("mv *.pdf ../docs")
  dirs = setdiff(dir(), pkgs)
  for (d in dirs)
    unlink(d, recursive=TRUE)
  
  setwd(root_path)
}



complete_readme = function(root_path, release_path, version, date)
{
  readme.in = readLines(paste0(root_path, "/assets/README.in"))
  readme = set_version(readme.in, version)
  readme = sub(readme, pattern="\\{DATE\\}", replacement=date)
  
  cat(readme, file=paste0(release_path, "/README"), sep="\n")
  
  TRUE
}

complete_notes = function(root_path, release_path)
{
  # pkgs = read.table(paste0(root_path, "/assets/spec.in"), sep=" ", header=TRUE, stringsAsFactors=FALSE)$Package
  # versions = lapply(paste0(release_path, "/src/", pkgs), get_version_from_tgz)
  
  # notes = readLines(paste0(root_path, "/assets/RELEASE.in"))
  
  # for (pkg in pkgs)
  # {
    
  #   notes = sub(notes, pattern="\\{VERSION\\}", replacement=date)
    
  # }
  
  # cat(notes, file=paste0(release_path, "/RELEASE"), sep="\n")
  
  TRUE
}

place_assets = function(root_path, release_path, version, date)
{
  asset_path = paste0(root_path, "/assets/")
  d = dir(path=asset_path)
  assets = d[grep(d, pattern="^((?!.in).)*$", perl=TRUE)]
  
  assets_dirs = assets[sapply(d, function(x) file.info(x)$isdir)]
  assets_files = setdiff(assets, assets_dirs)
  
  for (asset in assets_files)
    file.copy(from=paste0(asset_path, "/", asset), to=paste0(release_path, "/", asset))
  
  #TODO
  
  complete_readme(root_path, release_path, version, date)
  complete_notes(root_path, release_path)
  
  TRUE
}



#' make_src_dist
#' 
#' Make a source pbdR distribution.
#' 
#' @details
#' Downloads all packages as specified in the assets/spec.in file. CRAN packages
#' are the latest version. Github packages are the latest release (if none
#' exists, it'll break).
#' 
#' @param path
#' The root directory of the release project (or any of its subfolders). The
#' file \code{.release_home} has to exist in some parent of \code{path}.
#' @param version
#' A version string of the form \code{MAJOR.MINOR-PATCH}.
#' @param date
#' The release date.
#' @param verbose
#' Should the build system tell you what it's doing?
#' @param clobber
#' An option meant to stop you from accidentally overwriting an existing source
#' release because you forgot to bump the version in your calling script.
#' \code{TRUE}: remove existing directory should it exist;
#' \code{FALSE}: pass through initial creation checks;
#' \code{NULL}: receive a warning which you can override by manually typing 'OK'
#' which then deletes the existing dir and starts over (typing anything else
#' halts with an error).
#' 
#' @return
#' The return is silent, but on successful exit, the source distribution will be
#' located in the path 'releases/pbdR_${version}/'.
#' 
#' @examples
#' \dontrun{
#' library(pbdRelease)
#' 
#' make_src_dist(version="1.0-0", verbose=TRUE)
#' }
#' 
#' @export
make_src_dist = function(path=".", version, date=format(Sys.Date(), "%B %d %Y"), verbose=TRUE, clobber=NULL)
{
  vprint("setting up paths...", verbose)
  root_path = find_root(path)
  release_path = setup_release(root_path, version, clobber)
  vprint("ok!\n", verbose)
  
  vprint("getting source packages...", verbose)
  get_packages(root_path, release_path)
  vprint("ok!\n", verbose)
  
  vprint("building documentation...", verbose)
  build_docs(root_path, release_path)
  vprint("ok!\n", verbose)
  
  # NOTE must come after source packages have been placed
  vprint("placing assets...", verbose)
  place_assets(root_path, release_path, version, date)
  vprint("ok!\n", verbose)
  
  
  invisible(TRUE)
}
