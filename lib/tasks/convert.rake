namespace :convert do

  desc "Convert the detections"
  task(:detections, :needs => :environment) do
    convert(Detection)
  end

  def convert(model, batch_size=1000)
    model.find_in_batches(:batch_size => batch_size) do |records|
      records.each do |record|
        puts "#{record.sample_geo_accession} #{record.id_ref} #{record.abs_call} "
      end
    end
  end

end