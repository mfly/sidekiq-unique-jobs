# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SidekiqUniqueJobs::Timeout::Calculator do
  let(:calculator)         { described_class.new('class' => worker_class_name, 'at' => schedule_time) }
  let(:worker_class_name)  { 'MyUniqueJob' }
  let(:schedule_time)      { nil }

  describe 'public api' do
    subject { calculator }

    it { is_expected.to respond_to(:time_until_scheduled) }
    it { is_expected.to respond_to(:worker_class) }
    it { is_expected.to respond_to(:lock_expiration) }
    it { is_expected.to respond_to(:lock_timeout) }
    it { is_expected.to respond_to(:worker_options) }
    it { is_expected.to respond_to(:default_worker_options) }
  end

  describe '#time_until_scheduled' do
    subject { calculator.time_until_scheduled }

    context 'when not scheduled' do
      it { is_expected.to eq(0) }
    end

    context 'when scheduled' do
      let(:schedule_time) { Time.now.utc.to_i + 24 * 60 * 60 }
      let(:now_in_utc)    { Time.now.utc.to_i }

      it do
        Timecop.travel(Time.at(now_in_utc)) do
          is_expected.to be_within(1).of(schedule_time - now_in_utc)
        end
      end
    end
  end

  describe '#worker_class' do
    subject(:worker_class) { calculator.worker_class }

    let(:worker_class_name) { 'MyUniqueJob' }

    it { is_expected.to eq(MyUniqueJob) }
  end
end
