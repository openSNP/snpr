def ln(src, dst)
  run("ln -snf '#{src}' '#{dst}'")
end

def mkdir(path)
  run("[ -d '#{path}' ] || mkdir -p '#{path}'")
end
