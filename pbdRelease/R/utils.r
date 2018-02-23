find_root = function(path)
{
  setwd(path)
  
  nix_root = "/"
  win_root = "C:/"
  
  while (!file.exists(".release_home"))
  {
    wd = getwd()
    if (wd == nix_root || wd == win_root)
      stop("can't find project root")
    
    setwd("..")
  }
  
  getwd()
}



get_version_from_tgz = function(tgz)
{
  split = strsplit(tgz, split="(/|_)")[[1]]
  split[length(split)]
}



vprint = function(msg, verbose)
{
  if (isTRUE(verbose))
    cat(msg)
}



set_version = function(text, version)
{
  sub(text, pattern="\\{VERSION\\}", replacement=version)
}



file.move = function(from, to)
{
  file.copy(from=from, to=to)
  file.remove(from)
}
