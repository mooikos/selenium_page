# frozen_string_literal: true

module SeleniumPage
  # Page
  class Page
    require_relative 'page/errors'

    def self.configure_url(url)
      raise Errors::UnexpectedUrl unless url.is_a? String

      @url = url
    end

    def self.url
      @url
    end

    def self.element(element_name, element_selector, &block)
      define_method(element_name) do
        if block_given?
          find_element(element_selector, &block)
        else
          find_element(element_selector)
        end
      end
    end

    def self.elements(collection_name, collection_selector, &block)
      define_method(collection_name) do
        if block_given?
          find_elements(collection_selector, &block)
        else
          find_elements(collection_selector)
        end
      end
    end

    def initialize(driver)
      raise Errors::WrongDriver unless driver.is_a? Selenium::WebDriver::Driver

      @driver = driver
    end

    def url
      self.class.url
    end

    def get
      raise Errors::UrlNotSet unless self.class.url

      scheme_and_authority = SeleniumPage.scheme_and_authority
      raise Errors::SchemeAndAuthorityNotSet unless scheme_and_authority

      @driver.get scheme_and_authority + self.class.url
    end

    private

    def find_element(element_selector,
                     waiter = Selenium::WebDriver::Wait.new(
                       timeout: SeleniumPage.wait_time
                     ), &block)
      waiter.until do
        result = SeleniumPage::Element.new(
          @driver, @driver.find_element(:css, element_selector)
        )
        result.add_childrens(element_selector, &block)
        result
      end
    end

    def find_elements(collection_selector,
                     waiter = Selenium::WebDriver::Wait.new(
                       timeout: SeleniumPage.wait_time
                     ), &block)
      waiter.until do
        selenium_result = @driver.find_elements(:css, collection_selector)
        result = SeleniumPage::Element.new(
          @driver, @driver.find_element(:css, element_selector)
        )
        result.add_childrens(element_selector, &block)
        result
      end
    end
  end
end
