require 'ankusa'
require 'ankusa/file_system_storage'
require 'benchmark'
require 'stackprof'

# Onlty a benchmarking program would care about pre-caching the doc counts
# and vocab sizes instead of lazy loading them so rather than modify the
# ankusa gem and added this niche method we will monkey-patch it in here
module Ankusa
  module Classifier

    def initialize_cache
      puts "Initializing Classifier Cache"
      self.doc_count_totals
      self.vocab_sizes
    end

  end
end

module DontBayesMeBro

  class Benchmarker

    def initialize(test_count)
      @test_count = test_count.to_int
      @job_queue = Queue.new
    end

    def run
      puts "Benchmarking #{@test_count} emails"
      self.prepare_classifier
      self.populate_queue
      self.run_benchmark
    end

    protected

    def prepare_classifier
      puts "Preparing classifier"
      @storage = Ankusa::FileSystemStorage.new 'training/corpus'
      @classifier = Ankusa::NaiveBayesClassifier.new @storage
    end

    def populate_queue
      puts "Populating job queue"
      self.create_queue_file unless File.exist?("training/queue-#{@test_count}")

      puts "Reading file"
      @data = File.open("training/queue-#{@test_count}") {|f| Marshal.load(f)}

      puts "Populating Job Queue"
      @data.each {|email| @job_queue << email}

      puts "Job Queue populated with #{@job_queue.length} emails"
    end

    def create_queue_file
      puts "Generating file"
      data = []
      Dir['training/spam/**/*'].reject {|fn| File.directory?(fn) }.each do |file|
        break if data.length >= @test_count / 2
        begin
          body = Mail.read(file).body.to_s
          if body.length > 100
            data << body
            puts "PASSED: #{file} added"
          else
            puts "FAILED: #{file} not added due to small body"
          end
        rescue
          puts "FAILED: #{file} not added due to exception"
        end
      end

      Dir['training/ham/**/*'].reject {|fn| File.directory?(fn) }.each do |file|
        break if data.length >= @test_count
        begin
          body = Mail.read(file).body.to_s
          if body.length > 100
            data << body
            puts "PASSED: #{file} added"
          else
            puts "FAILED: #{file} not added due to small body"
          end
        rescue
          puts "FAILED: #{file} not added due to exception"
        end
      end
      File.open("training/queue-#{@test_count}",'w'){|f| Marshal.dump(data, f)}
      nil
    end

    def with_profiling
      StackProf.run(mode: :cpu, out: "/tmp/dbmb-#{Time.now.strftime('%Y%m%d%H%M%S')}.dump") do
        yield
      end
    end

    def benchmark
      Benchmark.bm(10) do |b|
        b.report @job_queue.length do
          while @job_queue.length > 0
            @classifier.classify @job_queue.pop
          end
        end
      end
    end

    def run_benchmark
      # Pre-calculate this before the performance tests
      @classifier.initialize_cache
      GC.start
      puts "Starting benchmark"
      ENV['PROFILE'] ? self.with_profiling { self.benchmark } : self.benchmark
    end

  end

end
