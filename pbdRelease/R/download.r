read_spec_file = function(root_path)
{
  read.table(paste0(root_path, "/assets/spec.in"), sep=" ", header=TRUE, stringsAsFactors=FALSE)
}



check_if_pkg_downloaded = function(dl_path, pkg)
{
  length(dir(dl_path, pattern=paste0(pkg, "_*"))) == 1
}



download_gh = function(root_path, dl_path, pkg)
{
  need_pkg = !check_if_pkg_downloaded(dl_path, pkg)
  if (!need_pkg)
    return(invisible(TRUE))
  
  td = tempdir()
  dir.create(paste0(td, "/pkg"))
  
  url = paste0("https://api.github.com/repos/RBigData/", pkg, "/releases/latest")
  tarball_url = jsonlite::read_json(url)$tarball_url
  
  destfile = paste0(td, "/pkg.tar.gz")
  destdir = paste0(td, "/pkg")
  curl::curl_download(tarball_url, destfile=destfile)
  
  system(paste("tar zxf", destfile, "-C", destdir, "--strip-components 1"))
  tools::Rcmd(paste("build", destdir, "--no-build-vignettes > /dev/null"))
  
  file.remove(destfile)
  pkg_file = dir(root_path, pattern="*.tar.gz")
  file.move(pkg_file, paste0(dl_path, "/", pkg_file))
  unlink(td, recursive=TRUE)
  
  invisible(TRUE)
}



download_cran = function(dl_path, pkg)
{
  need_pkg = !check_if_pkg_downloaded(dl_path, pkg)
  
  if (need_pkg)
    utils::download.packages(pkg, destdir=dl_path, quiet=TRUE)
  
  invisible(TRUE)
}



get_packages = function(root_path, release_path)
{
  pkgs = read_spec_file(root_path)
  pkgs.cran = pkgs[which(pkgs$Release.Loc == "cran"), ]$Package
  pkgs.gh = pkgs[which(pkgs$Release.Loc == "gh"), ]$Package
  
  dl_path = paste0(release_path, "/src")
  
  for (pkg in pkgs.cran)
    download_cran(dl_path, pkg)
  
  for (pkg in pkgs.gh)
    download_gh(root_path, dl_path, pkg)
  
  invisible(TRUE)
}
