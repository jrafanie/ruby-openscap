#
# Copyright (c) 2015 Red Hat Inc.
#
# This software is licensed to you under the GNU General Public License,
# version 2 (GPLv2). There is NO WARRANTY for this software, express or
# implied, including the implied warranties of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
# along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
#

require 'openscap/exceptions'
require 'openscap/text'
require 'openscap/xccdf/group'
require 'openscap/xccdf/rule'

module OpenSCAP
  module Xccdf
    class Item
      def self.build(t)
        fail OpenSCAP::OpenSCAPError, "Cannot initialize OpenSCAP::Xccdf::Item with #{t}" \
          unless t.is_a?(FFI::Pointer)
        # This is Abstract base class that enables you to build its child
        case OpenSCAP.xccdf_item_get_type t
        when :group
          OpenSCAP::Xccdf::Group.new t
        when :rule
          OpenSCAP::Xccdf::Rule.new t
        else
          fail OpenSCAP::OpenSCAPError, "Unknown Xccdf::Item type: #{OpenSCAP.xccdf_item_get_type t}"
        end
      end

      def initialize(t)
        if self.class == OpenSCAP::Xccdf::Item
          fail OpenSCAP::OpenSCAPError, 'Cannot initialize Xccdf::Item abstract base class.'
        end
        @raw = t
      end

      def id
        OpenSCAP.xccdf_item_get_id @raw
      end

      def sub_items
        @sub_items ||= sub_items_init
      end

      def destroy
        OpenSCAP.xccdf_item_free @raw
        @raw = nil
      end

      private

      def sub_items_init
        collect = {}
        items_it = OpenSCAP.xccdf_item_get_content @raw
        while OpenSCAP.xccdf_item_iterator_has_more items_it
          item_p = OpenSCAP.xccdf_item_iterator_next items_it
          item = OpenSCAP::Xccdf::Item.build item_p
          collect.merge! item.sub_items
          collect[item.id] = item
        end
        OpenSCAP.xccdf_item_iterator_free items_it
        collect
      end
    end
  end

  attach_function :xccdf_item_get_id, [:pointer], :string
  attach_function :xccdf_item_get_content, [:pointer], :pointer
  attach_function :xccdf_item_free, [:pointer], :void

  XccdfItemType = enum(:benchmark, 0x0100,
                       :profile, 0x0200,
                       :result, 0x0400,
                       :rule, 0x1000,
                       :group, 0x2000,
                       :value, 0x4000)
  attach_function :xccdf_item_get_type, [:pointer], XccdfItemType

  attach_function :xccdf_item_iterator_has_more, [:pointer], :bool
  attach_function :xccdf_item_iterator_next, [:pointer], :pointer
  attach_function :xccdf_item_iterator_free, [:pointer], :void
end