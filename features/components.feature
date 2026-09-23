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
    And the root should have data-sequence-fit="cover"
    And the root should have data-sequence-scroll-window-start="0.0"
    And the root should have data-sequence-scroll-window-end="1.0"
    And the picture should carry an img with width="1920" height="1080" and an empty alt
    And the renderer should not emit frame URLs, inline scripts, or runtime state

  Scenario: ImageSequence renders a supplied fit and scroll window
    Given an ImageSequence view model with:
      | property          | value                     |
      | source            | /sequences/hero           |
      | posterFirst       | /sequences/hero/first.jpg |
      | posterFinal       | /sequences/hero/final.jpg |
      | posterWidth       | 1920                      |
      | posterHeight      | 1080                      |
      | fit               | contain                   |
      | scrollWindowStart | 0.3                       |
      | scrollWindowEnd   | 0.65                      |
    When I render the ImageSequence component
    Then the root should have data-sequence-fit="contain"
    And the root should have data-sequence-scroll-window-start="0.3"
    And the root should have data-sequence-scroll-window-end="0.65"

  Scenario: ImageSequence attributes are optional for hand-authored markup
    Given a plain HTML element carrying data-paste-candidate-imagesequence, a poster, and a source
    And no data-sequence-fit, data-sequence-scroll-window-start, or data-sequence-scroll-window-end attributes
    When the Element initializes it
    Then it plays with fit "cover" across the scroll window 0 to 1
    And the rendered defaults match what the view model emits unset

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
      | fit              | an unknown fit           |
      | scrollWindowStart | a fraction below 0      |
      | scrollWindowEnd  | a fraction above 1       |
      | scrollWindowEnd  | not exceeding scrollWindowStart |
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

  Scenario Outline: paste.ui.form submits what the browser would have submitted
    Given a form[data-paste-form] inside an IO reply fragment target
    And the submitting button carries <attribute> "<value>"
    When the form is submitted with that button
    Then the request should use <effect>

    Examples:
      | attribute   | value                 | effect                              |
      | formaction  | /other                | the action /other                   |
      | formmethod  | get                   | the get method with a query string  |
      | formenctype | multipart/form-data   | a multipart body                    |
      | formtarget  | _self                 | the _self browsing context          |

  Scenario: paste.ui.form keeps the submitting button's entry in document order
    Given a form[data-paste-form] inside an IO reply fragment target
    And a field named "op" placed after the submitting button named "op"
    When the form is submitted with that button
    Then the request body should list the button's "op" entry before the field's

  Scenario Outline: paste.ui.form leaves submissions it cannot reproduce to the browser
    Given a form[data-paste-form] inside an IO reply fragment target with <configuration>
    When the form is submitted
    Then the submit event should not be prevented
    And no request should be sent

    Examples:
      | configuration                                                  |
      | a target of _blank                                             |
      | a submitting button with formtarget _blank                     |
      | a submitting button of type image                              |
      | method post and enctype text/plain                             |
      | a browser that does not report SubmitEvent.submitter           |
      | a browser without XMLHttpRequest.responseURL                   |
      | a browser whose FormData does not take the submitting button   |
      | a browser without WeakMap                                      |

  Scenario: paste.ui.io-reply-fragment-envelope places markup only
    Given a document containing a target named "list"
    When an envelope places markup containing a form[data-paste-form] into "list"
    Then the form should not be enhanced by the envelope Element

  Scenario: Form renders with defaults
    Given a Form view model with:
      | property | value      |
      | action   | /feedback  |
    And a trusted Html content slot
    When I render the Form component
    Then the HTML should contain element with class="paste-ui-form"
    And the HTML should contain action="/feedback"
    And the HTML should contain method="post"
    And the HTML should contain enctype="application/x-www-form-urlencoded"
    And the HTML should contain accept-charset="utf-8"
    And the HTML should not contain data-paste-form
    And the HTML should not contain id=
    And the HTML should not contain paste-ui-form-errors
    And the content slot should appear inside the form

  Scenario: Form with backgroundSubmit emits the Element attribute
    Given a Form view model with:
      | property         | value     |
      | action           | /feedback |
      | backgroundSubmit | true      |
      | id               | feedback  |
      | cssClass         | wide      |
    When I render the Form component
    Then the HTML should contain data-paste-form
    And the HTML should contain id="feedback"
    And the HTML should contain element with class="paste-ui-form wide"

  Scenario: Form renders form-level errors above the fields
    Given a Form view model with:
      | property | value      |
      | action   | /feedback  |
      | errors   | Try again  |
    When I render the Form component
    Then the HTML should contain a ul with class="paste-ui-form-errors" and role="alert"
    And the error list should appear before the content slot
    And each error should render as a li

  Scenario Outline: Form rejects invalid model configuration
    Given otherwise valid Form configuration
    When I construct a Form with <property> set to <value>
    Then construction should fail with an IllegalArgumentException
    And no component HTML should be rendered

    Examples:
      | property       | value                        |
      | action         | an empty string              |
      | action         | whitespace only              |
      | method         | an unknown method            |
      | enctype        | an unknown enctype           |
      | dataAttributes | a name containing a space    |

  Scenario: IO reply fragment target renders the named wrapper
    Given an IoReplyFragmentTarget view model with:
      | property | value    |
      | name     | feedback |
    And a trusted Html content slot
    When I render the IoReplyFragmentTarget component
    Then the HTML should contain element with class="paste-ui-io-reply-fragment-target"
    And the HTML should contain data-paste-io-reply-fragment-target="feedback"
    And the content slot should appear inside the target

  Scenario Outline: IoReplyFragmentTarget rejects invalid names
    Given otherwise valid IoReplyFragmentTarget configuration
    When I construct an IoReplyFragmentTarget with name set to <value>
    Then construction should fail with an IllegalArgumentException
    And no component HTML should be rendered

    Examples:
      | value                  |
      | an empty string        |
      | whitespace only        |
      | a name with a space    |
      | a name with a tab      |

  Scenario Outline: Rendering is selected from request headers
    Given a presenter view model
    When the request carries X-Requested-With "<xrw>" and Accept "<accept>"
    Then the selected rendering should be <rendering>

    Examples:
      | xrw                | accept                          | rendering       |
      |                    |                                 | Page            |
      |                    | text/html                       | Page            |
      |                    | */*                             | Page            |
      | XMLHttpRequest     | */*                             | IoReplyFragment |
      | xmlhttprequest     | text/html                       | IoReplyFragment |
      | fetch              | text/html                       | Page            |
      |                    | application/json                | Json            |
      |                    | application/json;q=0.9          | Json            |
      | XMLHttpRequest     | application/json                | Json            |
      | XMLHttpRequest     | application/json, text/html     | IoReplyFragment |
      |                    | text/html, application/json     | Page            |
      |                    | application/json;q=0            | Page            |
      | XMLHttpRequest     | application/json;q=0            | IoReplyFragment |
      |                    | text/html;q=0, application/json | Json            |
      |                    | ;                               | Page            |
      |                    | application/json, ;             | Json            |

  Scenario: One outcome carries one status code in every rendering
    Given a presenter view model whose outcome is a validation failure with status 400
    When the view model is rendered as Page, IoReplyFragment, and JSON
    Then every rendering should respond with status 400
    And every negotiated response should carry Vary "X-Requested-With, Accept"

  Scenario: IO reply fragment rendering emits the IO reply fragment template only
    Given a presenter view model rendered as IoReplyFragment
    Then the body should be the IO reply fragment template's output alone
    And the body should not contain html, head, or body elements
    And the body should not contain layout markup, asset includes, or inline script

  Scenario: JSON rendering without an encoder is not acceptable
    Given a presenter view model with no JSON encoder
    When the request selects the Json rendering
    Then no body should be rendered
    And the application should respond 406

  Scenario: IO reply fragment envelope success shape
    Given an IO reply fragment update succeeds with status 200
    Then the envelope meta should carry code 200, message "OK", and a finite time
    And the envelope data should carry fragments by name with markup, and optional js and css lists
    And the envelope data should carry variables as string values
    And the body should be application/json with Vary "X-Requested-With, Accept"

  Scenario: IO reply fragment envelope failure shape
    Given an IO reply fragment update fails with status 400
    Then the envelope meta should carry code 400, message "Bad Request", and a finite time
    And meta should carry error_type "param_error", error_code 400, and error_detail
    And the envelope data should be empty

  Scenario: paste.ui.io-reply-fragment-envelope applies an envelope only on success
    Given a document containing a div with data-paste-io-reply-fragment-target="feedback"
    When paste.ui.io-reply-fragment-envelope applies an envelope whose status or meta code is not 200
    Then the target content should be unchanged and the result should be 0
    When paste.ui.io-reply-fragment-envelope applies an envelope with status 200 and meta code 200
    Then each matching target's content should be replaced by its markup
    And elements with data-paste-io-reply-fragment-bind should receive the supplied variables
    And the result should be the number of target elements replaced, root included when it carries the attribute

  Scenario: paste.ui.form swaps HTML responses of any status
    Given a form[data-paste-form] inside a div with data-paste-io-reply-fragment-target="feedback"
    When the form is submitted
    Then the request should go through paste.io with X-Requested-With
    And the target should be aria-busy while in flight
    When the response arrives as text/html with status 400
    Then the target content should be replaced with the response body
    And forms inside the new content should be initialized
    And focus should move to the first role="alert" or role="status"

  Scenario: paste.ui.form leaves forms without an IO reply fragment target alone
    Given a form[data-paste-form] with no enclosing data-paste-io-reply-fragment-target
    When the form is submitted
    Then the submit event should not be prevented
    And no request should be sent

  Scenario: paste.ui.form resubmits natively on non-HTML or network failure
    Given a form[data-paste-form] inside an IO reply fragment target
    When the background request returns a non-HTML response or fails at the network level
    Then the form should be resubmitted natively with the same submitter
    And the re-fired submit should not be intercepted

  Scenario: paste.ui.form never places a response that left the page's origin
    Given a form[data-paste-form] inside an IO reply fragment target
    When the background request is redirected to a different origin and returns text/html
    Then the target content should be unchanged
    And the form should be resubmitted natively with the same submitter

  Scenario: paste.ui.form ignores submits while a request is in flight
    Given a form[data-paste-form] inside an IO reply fragment target with a request in flight
    When the form is submitted again
    Then the submit should be prevented
    And no second request should be sent

  Scenario Outline: paste.ui.form leaves cross-origin actions and unsupported methods alone
    Given a form[data-paste-form] inside an IO reply fragment target with <configuration>
    When the form is submitted
    Then the submit event should not be prevented
    And no request should be sent

    Examples:
      | configuration                              |
      | an action resolving to a different origin  |
      | a method other than get or post            |

  Scenario: paste.ui.form GET submit replaces the action's query
    Given a form[data-paste-form] inside an IO reply fragment target
    And the form has method "get" and an action carrying a query and a fragment
    When the form is submitted
    Then the request URL should carry the form's fields as its query
    And the action's original query and fragment should not appear in the request URL
