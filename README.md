# DontBayesMeBro

A Demonstration of bayesian filtering performance on ruby.

Quick and dirty for benchmarking, no tests, sue me.

## Installation

Clone this repository and bundle install

## Usage

Before you can run your tests you need to create a corpus for your bayesian filter to run off.

Therefore you will need a set of spam and ham emails to be saved in the appropriate directory
under the `training/spam` and `training/ham` folder (You can copy a folder structure
if you wish, the trainer looks through them recursively)

A good sample dataset to use is the Enron Email Dataset available at
http://www.cs.cmu.edu/~enron/enron_mail_20110402.tgz ( http://www.cs.cmu.edu/~enron/ )

This dataset has approximately 19,000 ham emails and 33,000 spam emails.

Once you have created the folders run

`rake train`

To create your corpus. This may take a while depending on the size of your source data. Once
it is finished you should have a corpus file of about 17MB in size.

## Contributing

1. Fork it ( https://github.com/[my-github-username]/dont_bayes_me_bro/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
