#
# Copyright (c) 2014 Red Hat Inc.
#
# This software is licensed to you under the GNU General Public License,
# version 2 (GPLv2). There is NO WARRANTY for this software, express or
# implied, including the implied warranties of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
# along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
#

require 'openscap/source'
require 'openscap/xccdf/testresult'
require 'common/testcase'

class TestSession < OpenSCAP::TestCase
  def test_testresult_new_bad
    source = OpenSCAP::Source.new('../data/xccdf.xml')
    assert !source.nil?
    msg = nil
    begin
      s = OpenSCAP::Xccdf::TestResult.new(source)
      assert false
    rescue OpenSCAP::OpenSCAPError => e
      msg = e.to_s
    end
    assert msg.start_with?("Expected 'TestResult' element while found 'Benchmark'."),
        "Message was: " + msg
  end

  def test_result_create_and_query_properties
    tr = new_tr
    assert tr.id == 'xccdf_org.open-scap_testresult_xccdf_org.ssgproject.content_profile_common',
        "TestResult.id was '#{tr.id}"
    assert tr.profile == 'xccdf_org.ssgproject.content_profile_common',
        "TestResult.profile was '#{tr.profile}'"
    tr.destroy
  end

  private
  def new_tr
    source = OpenSCAP::Source.new('../data/testresult.xml')
    assert !source.nil?
    tr = OpenSCAP::Xccdf::TestResult.new(source)
    source.destroy
    return tr
  end
end