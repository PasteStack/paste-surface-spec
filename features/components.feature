Feature: Surface Component Rendering
  As a paste-surface runtime implementation
  I need to render components with consistent HTML structure
  So that paste-elements JS modules can initialize correctly

  Scenario: Hero component renders with required data attributes
    Given a Hero view model with:
      | property        | value |
      | name            | main  |
      | showImage       | true  |
      | disableParallax | false |
      | stickyNavTarget | true  |
    When I render the Hero component
    Then the HTML should contain element with class="paste-ui-hero"
    And the HTML should contain id="hero-main"
    And the HTML should contain data-paste-hero="main"
    And the HTML should contain data-paste-parallax="true"
    And the HTML should contain data-paste-sticky-target="true"

  Scenario: Address component renders with schema.org markup
    Given an Address view model with:
      | property    | value       |
      | street1     | 123 Main St |
      | locality    | Springfield |
      | region      | IL          |
      | postalCode  | 62701       |
      | countryCode | USA         |
    When I render the Address component
    Then the HTML should contain itemtype="http://schema.org/PostalAddress"
    And the HTML should contain itemprop="streetAddress"
    And the HTML should contain itemprop="addressLocality"
    And the HTML should contain itemprop="addressRegion"
    And the HTML should contain itemprop="postalCode"
    And the HTML should contain itemprop="addressCountry"

  Scenario: PageMeta renders SEO tags
    Given a PageMeta view model with:
      | property    | value               |
      | siteName    | Example Site        |
      | title       | Home Page           |
      | description | Welcome to our site |
      | url         | example.com         |
    When I render the page head
    Then the HTML should contain <title>Home Page — Example Site</title>
    And the HTML should contain meta name="description"
    And the HTML should contain link rel="canonical"
    And the HTML should contain og:site_name meta tag

  Scenario: JSInclude renders JAM cacheable URL
    Given a JSInclude view model with:
      | property    | value                                     |
      | jamModules  | paste.dom,paste.event,paste.ui.heroscroll |
      | jamVersion  | 2025.02.02                                |
      | jamChecksum | abc123                                    |
    When I render the JS includes
    Then the output should contain a script tag with defer
    And the src should be a cacheable JAM path /paste/{version}/{checksum}/{modules}.min.js
    And the modules in the path should be sorted alphabetically

  Scenario: CSSInclude renders stylesheet link
    Given a CSSInclude view model with:
      | property      | value                               |
      | pasteIncludes | /css/paste.base.css,/css/paste.ui.css |
    When I render the CSS includes
    Then the output should contain a link rel="stylesheet" tag
    And the href should reference the included CSS paths
