require 'active_support/lib/abstract_unit'
require 'controller/fake_controllers'

require 'action_mailer'
require 'action_view'

ActionMailer::Base.send(:include, ActionView::Layouts)
ActionMailer::Base.view_paths = FIXTURE_LOAD_PATH

class AssertSelectTest < ActionController::TestCase
  Assertion = ActiveSupport::TestCase::Assertion

  class AssertSelectMailer < ActionMailer::Base
    def test(html)
      mail :body => html, :content_type => "text/html",
        :subject => "Test e-mail", :from => "test@test.host", :to => "test <test@test.host>"
    end
  end

  class AssertMultipartSelectMailer < ActionMailer::Base
    def test(options)
      mail :subject => "Test e-mail", :from => "test@test.host", :to => "test <test@test.host>" do |format|
        format.text { render :text => options[:text] }
        format.html { render :text => options[:html] }
      end
    end
  end

  class AssertSelectController < ActionController::Base
    def response_with=(content)
      @content = content
    end

    def response_with(&block)
      @update = block
    end

    def html()
      render :text=>@content, :layout=>false, :content_type=>Mime::HTML
      @content = nil
    end

    def xml()
      render :text=>@content, :layout=>false, :content_type=>Mime::XML
      @content = nil
    end
  end

  tests AssertSelectController

  def setup
    super
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
  end

  def teardown
    super
    ActionMailer::Base.deliveries.clear
  end

  #
  # Test assert_select_email
  #

  def test_assert_select_email
    assert_raise(Assertion) { assert_select_email {} }
    AssertSelectMailer.test("<div><p>foo</p><p>bar</p></div>").deliver
    assert_select_email do
      assert_select "div:root" do
        assert_select "p:first-child", "foo"
        assert_select "p:last-child", "bar"
      end
    end
  end

  def test_assert_select_email_multipart
    AssertMultipartSelectMailer.test(:html => "<div><p>foo</p><p>bar</p></div>", :text => 'foo bar').deliver
    assert_select_email do
      assert_select "div:root" do
        assert_select "p:first-child", "foo"
        assert_select "p:last-child", "bar"
      end
    end
  end
end