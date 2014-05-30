require 'mail'
require 'ankusa'
require 'ankusa/file_system_storage'

module DontBayesMeBro

  class Trainer

    attr_accessor :storage, :classifier

    def initialize
      self.storage = Ankusa::FileSystemStorage.new 'training/corpus'
      self.classifier = Ankusa::NaiveBayesClassifier.new storage
    end

    def train
      puts "This might take a while so open youtube and watch a rubyconf video"
      sleep 5
      t1 = Thread.new do
        Dir["training/spam/**/*"].reject {|fn| File.directory?(fn) }.each do |file|

          puts "reading #{file}"

          begin
            self.classifier.train :spam, Mail.read(file).body.raw_source
          rescue
          end

        end
      end

      t2 = Thread.new do
        Dir["training/ham/**/*"].reject {|fn| File.directory?(fn) }.each do |file|

          puts "reading #{file}"
          begin
            self.classifier.train :ham, Mail.read(file).body.raw_source
          rescue
          end

        end
      end

      t1.join
      t2.join

      storage.save

    end
  end
end
