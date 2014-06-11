require_relative 'lib/dont_bayes_me_bro'


desc 'Create a corpus of training data'
task :train do
  DontBayesMeBro::Trainer.new.train
end

namespace "benchmark" do

  [1000, 10_000, 30_000].each do |count|
    desc "#{count} emails"
    task :"#{count}" do
      DontBayesMeBro::Benchmarker.new(count).run
    end
  end

end
