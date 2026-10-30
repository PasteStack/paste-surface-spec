# Copyright (c) 2017–present Tomshley LLC
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

Feature: Surface Component Rendering
  As a paste-surface runtime implementation
  I need to render components with consistent HTML structure
  So that paste-elements JS modules can initialize correctly

  Scenario: Form selects one submission owner
    Given FormSubmission.Native, Apply or Html
    When I render the Form component
    Then every form should retain the paste-ui-form styling class
    And Apply should add only paste-ui-apply and require POST
    And Html should add only paste-ui-formhtml
    And Native should add no submission enhancement class
    And no mode should imply autosave

  Scenario: Lazy content retains a useful baseline and caller-owned timing
    Given LazyContent with a URL and fallback HTML
    When I render it
    Then the element should contain the escaped data-lazy-load URL and fallback content
    And loading paste.ui.lazy_loader alone should make no request
    And the owning page may request visible descendants after showing a panel

  Scenario: Carousel renders declarations while Elements owns generated controls
    Given a named Carousel with variableWidth, showCounter and animationEnabled
    When I render it with direct paste-ui-carousel-item children
    Then the root should declare the corresponding data-paste-carousel attributes
    And its wrap should contain the authored items track
    And the renderer should emit no generated arrows, indicators or pause button
    And without JavaScript every authored slide should remain available

  Scenario: Hero component renders with required data attributes
    Given a Hero view model with:
      | property        | value |
      | name            | main  |
      | showImage       | true  |
      | disableParallax | false |
      | stickyNavTarget | true  |
    When I render the Hero component
    Then the HTML should contain element with class="paste-ui-hero"
    And the HTML should contain id="main"
    And the HTML should contain data-paste-hero="main"
    And the HTML should contain data-paste-parallax="true"
    And the HTML should contain data-paste-sticky-target="true"

  Scenario: Hero with an image sequence keeps its image host and hands it to the Element
    Given a Hero view model named "main" with an ImageSequence
    When I render the Hero component
    Then the hero section should carry data-paste-scrollscrub with the declared scrub geometry
    And the image element should keep id="main-image" and class="paste-ui-hero-image"
    And the image element should carry data-paste-imagesequence="#main-image-catalog"
    And the section should carry class "paste-ui-hero-with-image" even without showImage
    And the HTML should contain script#main-image-catalog with type="application/json"
    And the HTML should not contain data-paste-parallax
    And the HTML should not contain a paste-ui-imagesequence-scope wrapper or a *-host id

  Scenario: ImageSequence renders the declarative wrapper and catalog
    Given an ImageSequence view model with a two-frame catalog
    When I render the ImageSequence component with media id "scene"
    Then the scope should have class="paste-ui-imagesequence-scope" and the boolean data-paste-scrollscrub attribute
    And the scope should carry data-scrub-start="top top" and data-scrub-end="bottom top"
    And the host should have class="paste-ui-imagesequence" and data-paste-imagesequence="#scene-catalog"
    And the host should have data-paste-progressiveresolution and aria-hidden="true"
    And the document should contain a script#scene-catalog with type="application/json" carrying the frames
    And the renderer should not emit runtime state, a poster element, or a skip control

  Scenario: ImageSequence emits declared scrub geometry only
    Given an ImageSequence view model whose scrub declares a subject, a window, and container mode is not declared
    When I render the ImageSequence component with media id "scene"
    Then the scope should carry the declared data-scrub-subject and data-scrub-window
    And the scope should not carry data-scrub-mode or data-scrub-root

  Scenario: ImageSequence in container mode emits only the applicable attributes
    Given an ImageSequence view model whose scrub declares container mode, a root, a subject, and a window
    When I render the ImageSequence component with media id "scene"
    Then the scope should carry data-scrub-mode="container", data-scrub-root, and data-scrub-window
    And the scope should not carry data-scrub-subject, data-scrub-start, or data-scrub-end

  Scenario: ImageSequence emits declared endpoints, buffer, and intro
    Given an ImageSequence view model with from, to, a scrub buffer, and an intro
    When I render the ImageSequence component with media id "scene"
    Then the host should carry data-sequence-from, data-sequence-to, and data-sequence-scrub-buffer-frames
    And the host should carry data-sequence-intro-duration-ms and data-sequence-intro-skip="#scene-skip"
    And the document should contain a hidden button#scene-skip with class="paste-ui-imagesequence-skip"
    And button#scene-skip should be the scope's first child, ahead of the host

  Scenario: A hero intro's skip control is the hero's first tab stop
    Given a Hero view model named "main" with an ImageSequence that declares an intro
    When I render the Hero component
    Then a hidden button#main-image-skip should be the section's first child
    And it should precede the image element and the content wrap

  Scenario: An intro without a skip renders no skip control
    Given an ImageSequence view model with an intro whose skip is false
    When I render the ImageSequence component with media id "scene"
    Then the host should carry data-sequence-intro-trigger="ready" and data-sequence-intro-duration-ms
    And the host should have no data-sequence-intro-skip attribute
    And no skip control and no element id "scene-skip" should be rendered
    And the same intro in a Hero named "main" should render no button#main-image-skip

  Scenario: An intro declares its skip by default
    Given an ImageSequence view model with an intro that does not set skip
    When I render the ImageSequence component with media id "scene"
    Then the host should carry data-sequence-intro-skip="#scene-skip"
    And the document should contain a hidden button#scene-skip labelled "Skip intro"

  Scenario: ImageSequence omits configuration the caller did not supply
    Given an ImageSequence view model with no intro, no endpoints, and no buffer
    When I render the ImageSequence component with media id "scene"
    Then the host should have no data-sequence-from or data-sequence-to attribute
    And the host should have no data-sequence-intro-* attribute
    And no skip control should be rendered

  Scenario: ImageSequence catalogs serialize inert and HTML-safe
    Given a catalog frame whose upgrade rungs were supplied unordered
    When I render the ImageSequence component
    Then the catalog JSON should list upgrades ascending in intrinsic width
    And a src containing "</script>" should appear as unicode escapes inside the data block

  Scenario: An adaptive tiered manifest normalizes into a catalog
    Given a version-1 manifest with two frames across two tiers
    When the adaptive adapter converts it with an identity resolver
    Then the catalog frame bases are the narrowest tier
    And each frame's upgrades are the wider tier in ascending order
    And producer metadata outside frames is not carried into the catalog

  Scenario: ImageSequence resolution opt-out omits the policy marker
    Given an ImageSequence view model with resolution false
    When I render the ImageSequence component
    Then the host should have no data-paste-progressiveresolution attribute

  Scenario: ProgressiveImage renders a standalone progressively resolved img
    Given a ProgressiveImage view model with a 640x360 base and one 1280x720 upgrade
    When I render the ProgressiveImage component
    Then the img should carry src, width="640", height="360", and the authored alt as its baseline
    And the img should have data-paste-progressiveresolution and data-image-sources="#still-sources"
    And the document should contain script#still-sources with type="application/json" carrying the base and its rungs
    And a src containing "</script>" should appear as unicode escapes inside the data block
    And no data-sequence-* or data-scrub-* attributes should be emitted

  Scenario: ImageSequence attributes are optional for hand-authored markup
    Given a plain HTML host carrying data-paste-imagesequence and a catalog inside a data-paste-scrollscrub scope
    And no other data-sequence-* attributes
    When the Element initializes it
    Then it plays the whole catalog across the declared scroll range
    And the authored baseline stays painted until a real frame is ready

  Scenario Outline: ImageSequence rejects invalid model configuration
    Given otherwise valid ImageSequence configuration
    When I construct the model with <property> set to <value>
    Then construction should fail with an IllegalArgumentException
    And no component HTML should be rendered

    Examples:
      | property          | value                                  |
      | catalog           | an empty frame list                    |
      | frame.src         | an empty string                        |
      | frame.width       | 0                                      |
      | frame.upgrades    | a rung at or under the base width      |
      | frame.upgrades    | repeated rung widths                   |
      | frame.upgrades    | a rung with a mismatched aspect        |
      | scrub.start       | a one-edge anchor                      |
      | scrub.start       | an unknown edge token                  |
      | scrub.window      | a start without an end                 |
      | scrub.windowStart | a fraction below 0                     |
      | scrub.windowEnd   | a fraction above 1                     |
      | scrub.windowEnd   | not exceeding scrub.windowStart        |
      | scrub.mode        | null                                   |
      | scrub.mode        | a null mode inside Some                |
      | scrub.subject     | whitespace only                        |
      | scrub.subject     | null                                   |
      | from              | an index beyond the catalog            |
      | to                | a negative index                       |
      | catalog           | one source at two intrinsic sizes      |
      | intro.to          | an index beyond the catalog            |
      | intro.durationMs  | zero — None is the no-intro state      |
      | intro.durationMs  | a negative duration                    |
      | intro.easing      | null                                   |
      | intro             | null                                   |
      | intro.skipLabel   | whitespace only                        |
      | intro.skipLabel   | null, with or without a skip           |
      | scrubBufferFrames | a negative count                       |

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

  Scenario: A jam recorded on the page dumps verbatim markup
    Given a Jam with js=[paste.dom,paste.event,paste.ui.heroscroll]
    And a fresh paste-assetgraph page object
    When the layout records the jam and dumps js
    Then the page should record one jam event with js=[paste.dom,paste.event,paste.ui.heroscroll]
    And the output should equal that page's js dump verbatim
    And the rendered output should compose no URL itself

  Scenario: A css jam carries its media through the page dump
    Given a Jam with css=[site.theme,site.palette] and media="print"
    And a fresh paste-assetgraph page object
    When the layout records the jam and dumps css
    Then the page should record one jam event with css=[site.theme,site.palette] and media="print"
    And the output should equal that page's css dump verbatim
    And the rendered output should compose no URL itself

  Scenario: A non-empty jam without a page object fails the render
    Given a Jam with js=[paste.dom,paste.event]
    And no paste-assetgraph page object
    When the layout records the jam
    Then the render should fail with an error naming the missing page

  Scenario: The root layout finishes the page and seals it
    Given a non-empty Jam and a fresh paste-assetgraph page object
    When I render the jambase layout with that page
    Then every jammed module reaches a dump of its type
    And the page reports finished once the layout's closing markup runs

  Scenario: A jam whose type never reaches a dump fails the page's finish
    Given a page that recorded css=[site.theme]
    And only js was dumped on that page
    When the page is finished
    Then the finish fails naming site.theme
    And the page remains unfinished so the missing dump can still be added

  Scenario: Recording and dumping never finish the page
    Given a non-empty Jam recorded and dumped on a fresh paste-assetgraph page
    Then the page remains unfinished
    # record/dump are partial operations — finish belongs to the root layout
    # or a host helper calling page.finish() after the full render, which is
    # idempotent against the layout's own finish

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

  Scenario: SectionNav item href overrides the generated fragment link
    Given a SectionNav view model with:
      | property | value |
      | sticky   | false |
    And nav items:
      | label    | targetId | href       |
      | Approach | approach | /#approach |
    When I render the SectionNav component
    Then the HTML should contain a[href="/#approach"] with text "Approach"

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
    And the HTML should not contain data-paste-smoothscroll

  Scenario: SectionNav declares smoothscroll only when asked
    Given a SectionNav view model with:
      | property     | value |
      | smoothscroll | true  |
    And nav items:
      | label | targetId |
      | About | about    |
    When I render the SectionNav component
    Then the HTML should contain element with class="paste-ui-section-nav"
    And the HTML should contain data-paste-smoothscroll

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
    Then each binding should reevaluate whether motion is eligible

  Scenario: Marquee binding preserves ownership across item changes
    Given equivalent plain HTML and Surface-rendered marquees with unrelated attributes and style properties
    When I change each list's item collection
    Then each binding should reevaluate eligibility and item spacing through its own observers
    And original nodes and their order should remain intact
    And unrelated attributes and style properties should remain unchanged

  Scenario Outline: paste.ui.form.form_html submits what the browser would have submitted
    Given a form.paste-ui-formhtml inside an IO reply fragment target
    And the submitting button carries <attribute> "<value>"
    When the form is submitted with that button
    Then the request should use <effect>

    Examples:
      | attribute   | value                 | effect                              |
      | formaction  | /other                | the action /other                   |
      | formmethod  | get                   | the get method with a query string  |
      | formenctype | multipart/form-data   | a multipart body                    |
      | formtarget  | _self                 | the _self browsing context          |

  Scenario: paste.ui.form.form_html keeps the submitting button's entry in document order
    Given a form.paste-ui-formhtml inside an IO reply fragment target
    And a field named "op" placed after the submitting button named "op"
    When the form is submitted with that button
    Then the request body should list the button's "op" entry before the field's

  Scenario Outline: paste.ui.form.form_html leaves submissions it cannot reproduce to the browser
    Given a form.paste-ui-formhtml inside an IO reply fragment target with <configuration>
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

  Scenario: autosave reply markup does not initialize unrelated enhancements
    Given a document containing a target named "list"
    When a successful autosave reply places markup containing a form.paste-ui-formhtml into "list"
    Then the form should not be enhanced by autosave

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

  Scenario: Form with Html submission emits the owning Element class
    Given a Form view model with:
      | property         | value     |
      | action           | /feedback |
      | submission       | Html      |
      | id               | feedback  |
      | cssClass         | wide      |
    When I render the Form component
    Then the HTML should contain class token "paste-ui-formhtml"
    And the HTML should contain id="feedback"
    And the HTML should contain element with class="paste-ui-form paste-ui-formhtml wide"

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

  Scenario: Metadata-only IO reply fragment envelope failure shape
    Given an error encoded by IoReplyFragmentEnvelope.failure with status 400
    Then the envelope meta should carry code 400, message "Bad Request", and a finite time
    And meta should carry error_type "param_error", error_code 400, and error_detail
    And the envelope data should be empty

  Scenario: autosave applies its reply only on success
    Given a document containing a div with data-paste-io-reply-fragment-target="feedback"
    When an autosave request returns a reply whose status or meta code is not 200
    Then the target content should be unchanged
    When an autosave request returns a reply with status 200 and meta code 200
    Then each matching target's content should be replaced by its markup
    And elements with data-paste-io-reply-fragment-bind should receive the supplied variables

  Scenario: paste.ui.form.form_html swaps HTML responses of any status
    Given a form.paste-ui-formhtml inside a div with data-paste-io-reply-fragment-target="feedback"
    When the form is submitted
    Then the request should go through paste.io with X-Requested-With
    And the target should carry aria-busy="true" and class token "paste-ui-formhtml-busy" while in flight
    And unrelated target classes should remain
    When the response arrives as text/html with status 400
    Then the target content should be replaced with the response body
    And forms inside the new content should be initialized
    And focus should move to the first role="alert" or role="status"
    And the target should no longer carry aria-busy or paste-ui-formhtml-busy

  Scenario: paste.ui.form.form_html leaves forms without an IO reply fragment target alone
    Given a form.paste-ui-formhtml with no enclosing data-paste-io-reply-fragment-target
    When the form is submitted
    Then the submit event should not be prevented
    And no request should be sent

  Scenario: paste.ui.form.form_html resubmits natively after transmission only when replay is declared safe
    Given a form.paste-ui-formhtml inside an IO reply fragment target
    When the background request returns an unsupported or malformed response or fails at the network level
    Then aria-busy and paste-ui-formhtml-busy should clear from the target before failure notification
    And the request should announce exactly one paste.ui.formhtml:failed event carrying its reason
    And an unmarked post form should not be resubmitted — a role="alert" failure notice appears in the form instead
    But a form carrying data-paste-form-idempotent, or a get submission, should be resubmitted natively with the same submitter
    And the re-fired submit should not be intercepted
    And a listener that cancels the failure event suppresses both the resubmit and the default notice

  Scenario: paste.ui.form.form_html never places a response that left the page's origin
    Given a form.paste-ui-formhtml inside an IO reply fragment target
    When the background request is redirected to a different origin and returns text/html
    Then the response markup is never placed in the target
    And the original form and its controls remain
    And the form should announce a paste.ui.formhtml:failed event with reason "response"
    And an unmarked post form should not be resubmitted — a role="alert" failure notice appears inside it

  Scenario: paste.ui.form.form_html ignores submits while a request is in flight
    Given a form.paste-ui-formhtml inside an IO reply fragment target with a request in flight
    When the form is submitted again
    Then the submit should be prevented
    And no second request should be sent
    And the owning request's busy markers should remain without an additional reason class

  Scenario: native radios and CSS provide the multistate baseline
    Given named radios, associated labels and panels authored as siblings
    And page CSS styles the checked radio's adjacent label and reveals its matching following panel
    When the visitor selects another radio with JavaScript unavailable
    Then native radio grouping should select only that choice
    And the label styling and panel visibility should follow the checked state
    And no data-multistate-state attribute or click subscription should be required

  Scenario: multistate enhances radio selection with history
    Given the same working radio and CSS baseline with paste.ui.multistate loaded
    When a radio changes
    Then the selected state should be reflected and written with pushState
    And the matching panels should carry data-multistate-state and the selected class
    When the visitor goes Back or Forward to a multistate entry
    Then the restored checked values should drive the same CSS presentation

  Scenario Outline: paste.ui.form.form_html leaves cross-origin actions and unsupported methods alone
    Given a form.paste-ui-formhtml inside an IO reply fragment target with <configuration>
    When the form is submitted
    Then the submit event should not be prevented
    And no request should be sent

    Examples:
      | configuration                              |
      | an action resolving to a different origin  |
      | a method other than get or post            |

  Scenario: paste.ui.form.form_html GET submit replaces the action's query
    Given a form.paste-ui-formhtml inside an IO reply fragment target
    And the form has method "get" and an action carrying a query and a fragment
    When the form is submitted
    Then the request URL should carry the form's fields as its query
    And the action's original query and fragment should not appear in the request URL

  Scenario: autosave owns applying its reply
    Given a form declaring data-ui-autosave and data-autosave-action
    When a successful autosave returns a Surface fragment envelope or an original module envelope
    Then autosave should apply its declared fragments and variables without a separate renderer module
    And autosave should acknowledge only the values sent in that request
    And edits made while it was pending should remain unacknowledged

  Scenario: native and background submission guards compose
    Given a background form with a submit button declaring data-prevent-double-submit="true"
    When the form starts a background request and cancels native submission
    Then the IO reply target should carry paste-ui-formhtml-busy until request settlement
    And no native-navigation lock should disable the submitter
    And no second request should be transmitted while that target is owned

  Scenario: text reflection and sorting preserve authored DOM
    Given text placeholders and fixed sortable slots authored in ordinary markup
    When a field value containing HTML is reflected
    Then it should appear as literal text while surrounding nodes remain intact
    When a slot is dragged onto another slot
    Then their content nodes should swap while structural order fields remain in place
    And live values and attached listeners should remain attached to those nodes


  Scenario: A select keeps native selection and reflects its visible option label
    Given a native select carrying data-paste-select
    And its next element sibling carries data-paste-select-value and aria-hidden true
    When paste.ui.select is loaded and another option is selected
    Then the sibling should contain the option's visible label as text
    And the select should retain its native name, value, focus, and form behavior
    And a completed native reset should restore the reflected default label

  Scenario: Select appearance has a working native baseline
    Given a Surface Select with an authored label and option content
    When JavaScript does not load
    Then the native select should remain visible, labelled, and usable
    And no generated id or ready marker should be required

  Scenario: Multistate radio values do not require marked content panels
    Given named radios carrying data-multistate-key and authored values
    And sibling CSS owns their presentation without data-multistate-value panels
    When the selected radio changes
    Then multistate should preserve the selected value in state and history
    And Back should restore the native radio selection

  Scenario: the original multistate markup receives native grouping
    Given radios with distinct values and one data-multistate-key but no names
    When paste.ui.multistate initializes
    Then the radios should receive the same GUID-suffixed native group name
    And existing authored names and ids should remain intact
    And missing ids should receive unique values

  Scenario: a later multistate address can clear an omitted dimension
    Given two selected dimensions and paste.ui.multistate loaded
    When the visitor navigates to an explicit state fragment naming only one dimension
    Then that dimension should select the requested value
    And the omitted dimension should have no checked radio or selected panel marker

  Scenario: Surface keeps the original multistate responsibility
    Given sibling radios and panels in an ordinary Twirl template
    Then Surface should emit no runtime selected marker or mirrored-strip adapter
    And it should not promise automatic form-reset state or history reconciliation


  Scenario: A named fragment target can explicitly request JSON
    Given an IoReplyFragmentTarget named "article" with format Json
    When I render the IoReplyFragmentTarget component
    Then its format attribute should be "json"
    And its name attribute should be "article"

  Scenario: A fragment article link remains an ordinary anchor
    Given an IoReplyFragmentLink with href "/articles/example" and target "article"
    When I render the IoReplyFragmentLink component
    Then its href should be "/articles/example"
    And data-paste-io-reply-fragment should be "article"
    And it should have no generated id or inline event handler

  Scenario: JSON and HTML can carry the same validation outcome
    Given a rendered fragment response with status 422 and validation markup
    When I encode it with IoReplyFragmentEnvelope.render
    Then meta.code should be 422
    And data.fragments should contain the rendered validation markup

  Scenario: Relative fragment resources use the destination URL
    Given an enhanced article link to a different directory
    When its validated reply contains relative iframe and CSS background URLs
    Then the destination URL should be committed before the markup is inserted
    And native resource requests should resolve against that destination
    But if the DOM write is refused the full page should replace that same history entry

  Scenario: A Logo anchor stays an ordinary anchor until scrolltop is declared
    Given a Logo with href "/" and no scrollTop declaration
    When I render the Logo component
    Then the anchor keeps href="/" and the paste-ui-logo class
    And it carries no data-paste-scrolltop attribute and no generated id or inline event handler

  Scenario: A Logo declaring scrollTop marks its own anchor
    Given a Logo with href "/" and scrollTop true
    When I render the Logo component
    Then the anchor keeps href="/" and the paste-ui-logo class
    And the anchor itself carries data-paste-scrolltop
    And without JavaScript the link still navigates to "/"
