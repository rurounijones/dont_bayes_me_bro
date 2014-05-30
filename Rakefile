require_relative 'lib/dont_bayes_me_bro'


desc 'Create a corpus of training data'
task :train do
  DontBayesMeBro::Trainer.new.train
end

namespace "benchmark" do

  desc "1000 emails"
  task :"1000" do
    DontBayesMeBro::Benchmarker.new(1000).run
  end

  desc "10000 emails"
  task :"10000" do
    DontBayesMeBro::Benchmarker.new(10000).run
  end

end
