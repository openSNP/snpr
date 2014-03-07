namespace :go_worker do
  desc "build go worker"
  task :build do
    working_dir = Rails.root.join('app/workers')
    system(<<-SH)
      cd #{working_dir}
      go get github.com/lib/pq
      go build -o goParser goParser.go
    SH
  end
end
