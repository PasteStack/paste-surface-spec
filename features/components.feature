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

  Scenario: Hero with an image sequence hands its media to the Element
    Given a Hero view model named "main" with an ImageSequence
    When I render the Hero component
    Then the HTML should contain data-paste-candidate-imagesequence
    And the HTML should contain id="main-image"
    And the HTML should contain data-sequence-progress-id="main"
    And the HTML should not contain data-paste-parallax
    And the HTML should not contain class="paste-ui-hero-image"

  Scenario: ImageSequence renders a readable poster and the Element's configuration
    Given an ImageSequence view model with:
      | property     | value                     |
      | source       | /sequences/hero           |
      | posterFirst  | /sequences/hero/first.jpg |
      | posterFinal  | /sequences/hero/final.jpg |
      | posterWidth  | 1920                      |
      | posterHeight | 1080                      |
      | range        | enter-exit                |
    When I render the ImageSequence component
    Then the root should have the boolean data-paste-candidate-imagesequence attribute
    And the root should have data-sequence-source="/sequences/hero"
    And the root should have data-sequence-range="enter-exit"
    And the root should have data-sequence-preload="auto"
    And the picture should carry an img with width="1920" height="1080" and an empty alt
    And the renderer should not emit frame URLs, inline scripts, or runtime state

  Scenario: ImageSequence poster candidates are emitted in ascending width
    Given an ImageSequence view model with poster candidates supplied out of order
    When I render the ImageSequence component
    Then the webp srcset descriptors should ascend by width
    And a reduced-motion source should offer the final frames
    And a non-webp source should appear only for candidates that supply fallbacks

  Scenario: ImageSequence omits configuration the caller did not supply
    Given an ImageSequence view model with no intro and no scroll endpoints
    When I render the ImageSequence component
    Then the root should have no data-sequence-scroll-from attribute
    And the root should have no data-sequence-scroll-to attribute
    And the root should have no data-sequence-intro-mode attribute
    And no skip control should be rendered

  Scenario Outline: ImageSequence rejects invalid model configuration
    Given otherwise valid ImageSequence configuration
    When I construct an ImageSequence with <property> set to <value>
    Then construction should fail with an IllegalArgumentException
    And no component HTML should be rendered

    Examples:
      | property         | value                    |
      | source           | an empty string          |
      | posterFirst      | whitespace only          |
      | posterWidth      | 0                        |
      | posterHeight     | -1                       |
      | range            | an unknown range         |
      | preload          | an unknown preload       |
      | priority         | -1                       |
      | progressTargetId | an id containing "#"     |
      | progressTargetId | an id containing a space |
      | scrollFrom       | supplied without scrollTo |
      | posterSources    | repeated widths          |
      | posterSources    | mismatched aspect ratios |

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
      | property          | value                                     |
      | jamModules        | paste.dom,paste.event,paste.ui.heroscroll |
      | jamVersion        | 1770465409                                |
      | jamModuleVersions | paste.dom=1.0,paste.ui.heroscroll=3.0     |
    When I render the JS includes
    Then the output should contain a script tag with defer
    And the src should be a cacheable JAM path /paste/{version}/{module+vN.0~...}.min.js
    And the path should carry exactly one segment before the module list
    And the modules in the path should use ~ as the separator
    And a module with a supplied version should carry its + version suffix
    And a module without a supplied version should appear as its bare name
    And the modules in the path should be sorted alphabetically

  Scenario: JSInclude JAM path omits versions when none are supplied
    Given a JSInclude view model with:
      | property   | value                    |
      | jamModules | paste.dom,paste.event    |
      | jamVersion | 2025.02.02               |
    When I render the JS includes
    Then the src should be /paste/2025.02.02/paste.dom~paste.event.min.js

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
      | label      | targetId      |
      | About      | introduction  |
      | Why Us     | why-choose-us |
      | Contact    | contact       |
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

  Scenario: Marquee renders a native list with default Element configuration
    Given a Marquee view model with:
      | property | value    |
      | label    | Partners |
    And 3 trusted Html content slots
    When I render the Marquee component
    Then the root should be a div with class="paste-ui-marquee"
    And the root should have the boolean data-paste-marquee attribute
    And the root should have data-paste-marquee-duration="45.0"
    And the root should have data-paste-marquee-pause-label="Pause motion"
    And the root should have data-paste-marquee-resume-label="Resume motion"
    And the root should have exactly 2 direct element children
    And the root should have exactly 1 direct ul with class="paste-ui-marquee-items" role="list" aria-label="Partners"
    And the list should have exactly 3 direct li elements with class="paste-ui-marquee-item"
    And the root should have exactly 1 direct button with class="paste-ui-marquee-toggle" type="button"
    And the button should have native hidden and disabled attributes
    And the button should have plain text "Pause motion"
    And the renderer should not add IDs, inline scripts, runtime state, or aria-pressed

  Scenario: Marquee maps custom configuration without implementing motion
    Given a Marquee view model with:
      | property        | value        |
      | label           | Partners     |
      | durationSeconds | 12.5         |
      | pauseLabel      | Stop motion  |
      | resumeLabel     | Start motion |
      | cssClass        | dark-theme   |
    And 3 trusted Html content slots
    When I render the Marquee component
    Then the root should be a div with class="paste-ui-marquee dark-theme"
    And the root should have data-paste-marquee-duration="12.5"
    And the root should have data-paste-marquee-pause-label="Stop motion"
    And the root should have data-paste-marquee-resume-label="Start motion"
    And the button should have plain text "Stop motion"
    And the button should have native hidden and disabled attributes
    And the renderer should not add animation styles or scripts

  Scenario: Marquee escapes configuration but preserves trusted rendered slots
    Given a Marquee view model whose label, pauseLabel, resumeLabel, and cssClass contain HTML metacharacters
    And trusted Html slots containing nested and sibling elements
    When I render the Marquee component
    Then the model strings should be HTML-escaped in attributes and button text
    And the model strings should not create new attributes or elements
    And each trusted Html slot should remain markup rather than escaped text
    And each slot should appear exactly once in its own direct li wrapper
    And the slot order should match the supplied sequence
    And the renderer should not add duplicate tracks or extra content wrappers

  Scenario Outline: Marquee preserves slot cardinality for small collections
    Given a Marquee view model with label "Partners"
    And <count> trusted Html content slots
    When I render the Marquee component
    Then the list should have exactly <count> direct li elements with class="paste-ui-marquee-item"
    And the root should still have exactly 1 native list and 1 hidden disabled toggle

    Examples:
      | count |
      | 0     |
      | 1     |
      | 3     |

  Scenario: Marquee preserves empty and repeated supplied slots
    Given a Marquee view model with label "Partners"
    And 2 identical trusted Html slots followed by 1 empty Html slot
    When I render the Marquee component
    Then the list should have exactly 3 direct li elements with class="paste-ui-marquee-item"
    And the repeated content should appear exactly twice in supplied order
    And the last li should be empty

  Scenario Outline: Marquee rejects invalid model configuration
    Given otherwise valid Marquee configuration
    When I construct a Marquee with <property> set to <value>
    Then construction should fail with an IllegalArgumentException
    And no component HTML should be rendered

    Examples:
      | property        | value             |
      | label           | an empty string   |
      | label           | whitespace only   |
      | label           | null              |
      | pauseLabel      | an empty string   |
      | pauseLabel      | whitespace only   |
      | pauseLabel      | null              |
      | resumeLabel     | an empty string   |
      | resumeLabel     | whitespace only   |
      | resumeLabel     | null              |
      | durationSeconds | 0.0               |
      | durationSeconds | -1.0              |
      | durationSeconds | NaN               |
      | durationSeconds | positive infinity |
      | durationSeconds | negative infinity |

  Scenario Outline: Plain HTML and Surface output share a readable no-JavaScript fallback
    Given a marquee supplied as <markup>
    And JavaScript is disabled
    When paste.ui.marquee CSS is loaded
    Then the list should wrap and expose every original item in supplied order
    And the toggle should remain hidden and disabled
    And no copies of the items should be created
    When the marquee CSS is unavailable
    Then the native list should still expose every original item

    Examples:
      | markup                   |
      | plain contract HTML      |
      | equivalent Surface HTML  |

  Scenario Outline: Enhancement refuses unsafe or unsupported motion
    Given equivalent plain HTML and Surface-rendered marquees
    And <condition>
    When paste.ui.marquee initializes each root
    Then each root should have data-paste-marquee-state="static"
    And every original item should be exposed in a readable list in supplied order
    And each toggle should be hidden and disabled
    And links and forms should remain usable

    Examples:
      | condition                                                   |
      | motion is disabled                                          |
      | reduced motion is preferred                                 |
      | the Element CSS is unavailable                              |
      | ResizeObserver is unavailable                               |
      | matchMedia is unavailable                                   |
      | fewer than two items are supplied                           |
      | item rendered widths are unequal                            |
      | items contain interactive content                           |
      | cycle distance is smaller than viewport width plus one item |

  Scenario: Eligible marquee motion uses original items and CSS timing
    Given equivalent plain HTML and Surface-rendered marquees with default configuration
    And the Element CSS, ResizeObserver, and matchMedia are available
    And reduced motion is not preferred
    And each marquee has at least 2 noninteractive items of equal rendered width
    And each cycle distance is at least its viewport width plus one item width
    When paste.ui.marquee initializes each root
    Then each root should have data-paste-marquee-state="running"
    And the items should use CSS transform animations with individual phase offsets over 45 seconds
    And each animation should reset only while its item is fully outside the viewport
    And JavaScript should not run an animation tick loop or refresh-rate pixel locking
    And no original nodes should be cloned or reordered
    And each toggle should be visible and enabled with plain text "Pause motion"

  Scenario: Pause exposes originals and resume restarts motion
    Given equivalent plain HTML and Surface-rendered marquees that are running
    When I activate each pause toggle
    Then each root should have data-paste-marquee-state="paused"
    And every original item should be exposed in a static wrapping list
    And each toggle should have plain text "Resume motion" without aria-pressed
    When I activate each resume toggle
    Then each eligible root should have data-paste-marquee-state="running"
    And motion should restart rather than preserve the previous animation position
    And each toggle should have plain text "Pause motion" without aria-pressed

  Scenario: Focus and changed reduced-motion preferences restore readable content
    Given equivalent plain HTML and Surface-rendered marquees that are running
    When focus enters an item in each marquee
    Then every original item should be exposed in a static readable list
    When the reduced-motion preference changes to reduce
    Then each root should have data-paste-marquee-state="static"
    And each toggle should be hidden and disabled
    When the preference changes back
    Then each controller should reevaluate whether motion is eligible

  Scenario: Marquee initialization, refresh, and disposal preserve ownership
    Given equivalent plain HTML and Surface-rendered marquees with unrelated attributes and style properties
    When I call init twice for each root
    Then repeated initialization should return the same controller for that root
    When I change each list's item collection and call refresh
    Then each controller should reevaluate eligibility and item spacing without requiring mutation observation
    When I call dispose on each controller
    Then the Element's observers and listeners should be removed
    And attributes and style properties owned by the Element should be restored
    And original nodes and their order should remain intact
    And unrelated attributes and style properties should remain unchanged
