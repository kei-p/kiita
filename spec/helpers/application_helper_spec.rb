require 'rails_helper'

describe ApplicationHelper do
  describe '#markdown' do
    subject { helper.markdown(body) }

    let(:body) do
      <<-EOS.gsub(/^\s+/, '')
      # tables
      | header | header | header |
      |:--:|:--:|:--:|
      |column|column|column|

      # autolink
      http://example.com

      # script injection
      <script>alert(\'hoge\');</script>
      EOS
    end

    it { is_expected.to include('<table>') }
    it { is_expected.to include('<a href="http://example.com">http://example.com</a>') }
    it { is_expected.not_to include('<script>') }
  end
end
