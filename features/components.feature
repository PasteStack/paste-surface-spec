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

  Scenario: SectionNav component renders with sticky nav data attribute
    Given a SectionNav view model with:
      | property | value |
      | sticky   | true  |
    And nav items:
      | label      | targetId          |
      | About      | introduction      |
      | Why Us     | why-choose-us |
      | Contact    | contact           |
    When I render the SectionNav component
    Then the HTML should contain element with class="paste-ui-section-nav"
    And the HTML should contain data-paste-sticky-nav
    And the HTML should contain element with class="paste-ui-section-nav-items"
    And the HTML should contain 3 elements with class="paste-ui-section-nav-item"
    And the HTML should contain a[href="#introduction"] with text "About"
    And the HTML should contain a[href="#why-choose-us"] with text "Why Us"
    And the HTML should contain a[href="#contact"] with text "Contact"

  Scenario: SectionNav without sticky does not emit data attribute
    Given a SectionNav view model with:
      | property | value |
      | sticky   | false |
    And nav items:
      | label | targetId |
      | About | about    |
    When I render the SectionNav component
    Then the HTML should contain element with class="paste-ui-section-nav"
    And the HTML should not contain data-paste-sticky-nav

  Scenario: SectionNav with custom CSS classes
    Given a SectionNav view model with:
      | property | value        |
      | sticky   | true         |
      | cssClass | dark-theme   |
    And nav items:
      | label   | targetId | cssClass |
      | About   | about    | active   |
      | Contact | contact  |          |
    When I render the SectionNav component
    Then the HTML should contain element with class="paste-ui-section-nav dark-theme"
    And the HTML should contain li with class="paste-ui-section-nav-item active"
