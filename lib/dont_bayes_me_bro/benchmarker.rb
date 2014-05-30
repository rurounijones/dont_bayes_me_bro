require 'ankusa'
require 'ankusa/file_system_storage'
require 'benchmark'
require 'stackprof'

module DontBayesMeBro

  class Benchmarker

    def initialize(test_count)
      @test_count = test_count.to_int
      @queue = Queue.new
    end

    def run
      puts "Benchmarking #{@test_count} emails"
      self.prepare_classifier
      self.populate_queue
      self.run_benchmark
    end

    def prepare_classifier
      puts "Preparing classifier"
      @storage = Ankusa::FileSystemStorage.new 'training/corpus'
      @classifier = Ankusa::NaiveBayesClassifier.new @storage
    end

    def populate_queue
      puts "Populating job queue"
      t1 = Thread.new do
        Dir['training/spam/**/*'].reject {|fn| File.directory?(fn) }.each do |file|
          break if @queue.length >= @test_count
          begin
            @queue << Mail.read(file).body.raw_source
          rescue
          end

        end
      end

      t2 = Thread.new do
        Dir['training/ham/**/*'].reject {|fn| File.directory?(fn) }.each do |file|
          break if @queue.length >= @test_count
          begin
            @queue << Mail.read(file).body.raw_source
          rescue
          end

        end

      end
      t1.join
      t2.join
      # In case a race condition caused one of the threads to push one extra email
      # to the queue.
      @queue.pop if @queue.length > @test_count
      puts "Queue populated with #{@queue.length} emails"
      # Pre-calculate this before the performance tests
      @storage.get_vocabulary_sizes
    end


    def run_benchmark
      puts "Starting benchmark"
      StackProf.run(mode: :cpu, out: "/tmp/dontbayesmebro#{Time.now.strftime('%Y%m%d%H%M%S')}.dump") do
        Benchmark.bm(10) do |b|
          b.report @queue.length do
            while @queue.length > 0
              @classifier.classify @queue.pop
            end
          end
        end
      end
    end

  end

end
