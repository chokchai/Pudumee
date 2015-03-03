# apply css
$('html').addClass('pudu')

# vars

current_url = "" + window.location.href

# page

pages =
  thread: current_url.indexOf('.com/thread/') != -1
  board: current_url.indexOf('.com/board/') != -1

# $elements

$elements =
  controlBar: $('.posts > .control-bar')
  postHeader: $('.posts .content-head')
  threads: $('.threads .thread')

# watcher
# [we need watcher because some function in this forum using ajax update]

pudu.watcherLoop() # start watcher

# ========== BOARD ========= #

if pages.board

  pudu.watcher['thread_title_link_to_front_page'] = ->

    pudu.watcherElementIterator $elements.threads, ($ele)->
      $l = $ele.find('.link.target > a')

      # edit link url
      $l.attr 'href', $l.attr('href').replace('s/recent/', '/') + '?page=1'

# ========== THREAD ========= #

if pages.thread

  #=== add pagination to bottom ===#

  pudu.watcher['add_thread_pagination'] = ->

    page = $elements.controlBar.find('.state-selected').text() # page number

    # updated ?
    if $elements.controlBar.data('page') != page

      # clone pagination
      $ctb = $elements.controlBar.clone()
      $ctb.find('> div').remove() # remove all eles except pagination

      # wrap with div to prevent js selector
      ctbHtml = '<div class="control-bar ui-helper-clearfix pudu-thread-pagination" style="text-align: center"><div>' + $ctb.html() + '</div></div>'

      $('.pudu-thread-pagination').remove() # remove old if exist
      $('.posts > .content').after ctbHtml

      # save current page number
      $elements.controlBar.data 'page', page

  #=== add focus to liked comment ===#

  pudu.watcher['add_focus_to_comment'] = ->

    # each comment
    pudu.watcherElementIterator $('.posts .content-head'), ($ele, that)->

      # have like
      if $('.likes a', that).size() > 0

        # like < 10
        if $('.view-likes', that).size() == 0
          focus = 1
        else
          score = 2 + parseInt $('.view-likes', that).text().replace([' more', ','], '')
          if score < 10
            focus = 2
          else if score < 20
            focus = 3
          else if score < 30
            focus = 4
          else if score < 40
            focus = 5

        # add focus to post
        $(that).parents('article').addClass('focus-'+focus)

        # fix margin
        $(that).parent().find('.message').css 'margin': 0, 'minHeight': 285
