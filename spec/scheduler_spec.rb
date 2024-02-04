require 'activerecord-import'

RSpec.describe Scheduler do

  def setup_database_records(example_file)
    shows = []
    File.read(example_file).each_line do |line|
      id, quantity, last_update = line.split(",")
      shows << Show.new(id: id, quantity: quantity, last_update: last_update)
    end
    Show.import shows
  end

  context "example 1", vcr: { cassette_name: "example1" } do
    let(:example_file) { "spec/fixtures/example1.txt" }
    let(:needs_updating) { [1, 2] }
    let(:updates_hash) { { 1 => 0, 2 => 15 } }

    it "finds the IDs that need updating" do
      setup_database_records(example_file)
      scheduler = Scheduler.new
      result = scheduler.shows_to_update
      expect(result).to match_array needs_updating
    end

    it "creates the update schedule" do
      scheduler = Scheduler.new
      allow(scheduler).to receive(:shows_to_update).and_return(needs_updating)
      scheduled = scheduler.schedule_show_updates
      expect(scheduled).to eq(updates_hash) # replace this hash with the correct schedule
    end
  end

  context "example 2", vcr: { cassette_name: "example2" } do
    let(:example_file) { "spec/fixtures/example2.txt" }
    let(:needs_updating) { [2, 4] }
    let(:updates_hash) { { 2 => 0, 4 => 15 } }

    it "finds the IDs that need updating" do
      setup_database_records(example_file)
      scheduler = Scheduler.new
      result = scheduler.shows_to_update
      expect(result).to match_array needs_updating
    end

    it "creates the update schedule" do
      scheduler = Scheduler.new
      allow(scheduler).to receive(:shows_to_update).and_return(needs_updating)
      scheduled = scheduler.schedule_show_updates
      expect(scheduled).to eq(updates_hash) # replace this hash with the correct schedule
    end
  end

  context "example 3", vcr: { cassette_name: "example3" } do
    let(:example_file) { "spec/fixtures/example3.txt" }
    # These are the show IDs that need updating
    let(:needs_updating) { File.read("spec/fixtures/example3-updates.txt").split.map(&:to_i) }
    let(:updates_hash) { JSON.parse(File.read("spec/fixtures/example3-update-hash.json")).transform_keys(&:to_i) }

    it "finds the IDs that need updating" do
      setup_database_records(example_file)
      scheduler = Scheduler.new
      result = scheduler.shows_to_update
      expect(result).to match_array needs_updating
    end

    it "creates the update schedule" do
      scheduler = Scheduler.new
      allow(scheduler).to receive(:shows_to_update).and_return(needs_updating)
      scheduled = scheduler.schedule_show_updates
      expect(scheduled).to eq(updates_hash) # replace this hash with the correct schedule
    end
  end
end
