require 'spec_helper'
require_relative '../../../lib/generators/brain_damage/lib/ruby_simple_parser/parser'

describe RubySimpleParser::LineClassifier do
  subject { RubySimpleParser::LineClassifier.new }

  describe '.strip_block_wrappers' do
    it 'strips only block defining tokens' do
      expect(subject.strip_block_wrappers('  before_save :alface')).to eq []
      expect(subject.strip_block_wrappers('        ifolia @contact.errors.empty?')).to eq []
      expect(subject.strip_block_wrappers('  scope :alface, -> { |limonada| ')).to eq ['{']
      expect(subject.strip_block_wrappers('  validate :queijo, only: do |alface| ')).to eq ['do']
      expect(subject.strip_block_wrappers('        if @contact.errors.empty?')).to eq ['if']
      expect(subject.strip_block_wrappers('alfaces.map{ |queijo|')).to eq ['{']
    end
  end

  describe '.block_balance' do
    it 'returns the block balance' do
      expect(subject.block_balance('  before_save :alface')).to eq 0
      expect(subject.block_balance('        ifolia @contact.errors.empty?')).to eq 0
      expect(subject.block_balance('  before_save :dominion')).to eq 0


      expect(subject.block_balance('  scope :alface, -> { |limonada| ')).to eq 1
      expect(subject.block_balance('  validate :queijo, only: do |alface| ')).to eq 1
      expect(subject.block_balance('        if @contact.errors.empty?')).to eq 1
      expect(subject.block_balance('alfaces.map{ |queijo|')).to eq 1

      expect(subject.block_balance('end')).to eq -1
      expect(subject.block_balance('    end')).to eq -1
      expect(subject.block_balance('    }')).to eq -1
      expect(subject.block_balance('end.map()')).to eq -1
      expect(subject.block_balance('end.map{ |alface| alface.queijo }')).to eq -1
      expect(subject.block_balance('}.map{ |alface| alface.queijo }')).to eq -1
      expect(subject.block_balance('errors: @contact.errors }')).to eq -1
    end
  end

  describe '.classify' do
    it 'classifies method openings' do
      expect(subject.classify('  def create')).to eq RubySimpleParser::METHOD_START
      expect(subject.classify('  def create alface')).to eq RubySimpleParser::METHOD_START
      expect(subject.classify('  def create(goiaba, limao)')).to eq RubySimpleParser::METHOD_START
      expect(subject.classify('    def create')).to eq RubySimpleParser::METHOD_START
      expect(subject.classify('    def create alface')).to eq RubySimpleParser::METHOD_START
      expect(subject.classify('    def create(goiaba, limao)')).to eq RubySimpleParser::METHOD_START
    end

    it 'classifies comments' do
      expect(subject.classify('# alface')).to eq RubySimpleParser::COMMENT
      expect(subject.classify('   # alface')).to eq RubySimpleParser::COMMENT
      expect(subject.classify('     ### alface')).to eq RubySimpleParser::COMMENT

      expect(subject.classify('  def goiabada ### alface')).not_to eq RubySimpleParser::COMMENT
    end

    it 'classifies empty lines' do
      expect(subject.classify('')).to eq RubySimpleParser::EMPTY
      expect(subject.classify('      ')).to eq RubySimpleParser::EMPTY
    end

    it 'classifies class definitions' do
      expect(subject.classify('class ContactsController < ApplicationController')).to eq RubySimpleParser::CLASS_START
    end

    it 'classifies code without block' do
      expect(subject.classify('  before_save :alface')).to eq RubySimpleParser::CODE_WITHOUT_BLOCK
      expect(subject.classify('  before_save :dominion')).to eq RubySimpleParser::CODE_WITHOUT_BLOCK
      expect(subject.classify('  include Autocompletable')).to eq RubySimpleParser::CODE_WITHOUT_BLOCK
      expect(subject.classify('  set_before_filter :alface, only: [:queijo] ')).to eq RubySimpleParser::CODE_WITHOUT_BLOCK
      expect(subject.classify('  return true if @contact.errors.empty?')).to eq RubySimpleParser::CODE_WITHOUT_BLOCK
      expect(subject.classify('alfaces.map(&:queijo)')).to eq RubySimpleParser::CODE_WITHOUT_BLOCK
      expect(subject.classify('alfaces.map{ |queijo| queijo.goiabada }')).to eq RubySimpleParser::CODE_WITHOUT_BLOCK
      expect(subject.classify('        ifolia @contact.errors.empty?')).to eq RubySimpleParser::CODE_WITHOUT_BLOCK
    end

    it 'classifies code with block' do
      expect(subject.classify('  scope :alface, -> {')).to eq RubySimpleParser::CODE_WITH_BLOCK
      expect(subject.classify('  scope :alface, -> { |limonada| ')).to eq RubySimpleParser::CODE_WITH_BLOCK
      expect(subject.classify('  validate :queijo, only: do')).to eq RubySimpleParser::CODE_WITH_BLOCK
      expect(subject.classify('  validate :queijo, only: do |alface| ')).to eq RubySimpleParser::CODE_WITH_BLOCK
      expect(subject.classify('        if @contact.errors.empty?')).to eq RubySimpleParser::CODE_WITH_BLOCK
      expect(subject.classify('alfaces.map{ |queijo|')).to eq RubySimpleParser::CODE_WITH_BLOCK
    end

    it 'classifies block ending' do
      expect(subject.classify('end')).to eq RubySimpleParser::BLOCK_END
      expect(subject.classify('    end')).to eq RubySimpleParser::BLOCK_END
      expect(subject.classify('    }')).to eq RubySimpleParser::BLOCK_END
      expect(subject.classify('end.map()')).to eq RubySimpleParser::BLOCK_END
      expect(subject.classify('end.map{ |alface| alface.queijo }')).to eq RubySimpleParser::BLOCK_END
      expect(subject.classify('}.map{ |alface| alface.queijo }')).to eq RubySimpleParser::BLOCK_END
      expect(subject.classify('errors: @contact.errors }')).to eq RubySimpleParser::BLOCK_END
    end

    it 'classifies block swaping as other' do
      expect(subject.classify('end.map {')).to eq RubySimpleParser::CODE_WITHOUT_BLOCK
      expect(subject.classify('}.map {')).to eq RubySimpleParser::CODE_WITHOUT_BLOCK
      expect(subject.classify('}.select { |something| ')).to eq RubySimpleParser::CODE_WITHOUT_BLOCK
    end

    it 'classifies everything else as other' do
    end
  end
end
