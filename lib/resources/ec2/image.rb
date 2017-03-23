module Serverspec
  module Type
    module AWS
      # The EC2 module contains the EC2 API resources
      module EC2
        # The Instance class exposes the EC2::Image resources
        class Image < Base
          # The ID of the Instance
          attr_reader :instance_id
          # The Name tag of the Instance (if available)
          attr_reader :image_name

          # AWS SDK for Ruby v2 Aws::EC2::Client wrapper for initializing an
          # Instance resource
          # @param image_id_name [Array] The ID or Name tag of the Image
          # @param instance [Class] Aws::EC2::Client instance
          # @raise [RuntimeError] if image_id_name.nil?
          # @raise [RuntimeError] if image_id_name.length == 0
          # @raise [RuntimeError] if image_id_name.length > 1
          def initialize(image_id_name, instance = nil)
            check_init_arg 'image_id_name', 'EC2::image', image_id_name
            @aws = instance.nil? ? Aws::EC2::Client.new : instance
            if image_id_name.match(/^ami-[A-Fa-f0-9]{8,17}$/).nil?
              @image_name = image_id_name
              get_image_by_name image_id_name
            else
              @image_id = image_id_name
              get_image_by_id image_id_name
            end
          end

          # Returns the string representation of EC2::Instance
          # @return [String]
          def to_s
            return "EC2 Image ID: #{@image_id}" if @image_name.nil?
            "EC2 Image ID: #{@image_id}; Name: #{@image_name}"
          end

          def root_volume
            root_vol = @image.block_device_mappings.first do |vol|
              vol.device_name == @image.root_device_name
            end
            Volume.new(root_vol, @image.root_device_type)
          end

          attr_reader :image_id

          attr_reader :image_name

          private

          # @private
          def get_image_by_id(id)
            results = @aws.describe_images(image_ids: [id])
            @image = results.images[0]
            @image_name = @image.name
          end

          # @private
          def get_image_by_name(name)
            @image = @aws.describe_images(
              filters: [
                { name: 'name', values: [name] },
                { name: 'state', values: ['available'] }
              ]
            ).images[0]
            @image_id = @image.image_id
            @image_name = @image.name
          end
        end

        # The Volume class exposes the image root volume
        # as Aws::EC2::Types::BlockDeviceMapping
        class Volume < Base
          def initialize(vol, volume_type)
            @volume = vol
            @type = volume_type
          end

          def encrypted?
            @volume.ebs.encrypted
          end

          def snapshot_id
            @volume.ebs.snapshot_id
          end

          def device_name
            @volume.device_name
          end

          attr_reader :type

          # Returns the string representation of EC2::RootVolume
          # @return [String]
          def to_s
            "EC2 Image Root Volume: #{@volume.ebs.snapshot_id}"
          end
        end
      end
    end
  end
end
