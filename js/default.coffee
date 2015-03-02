# apply css
$('html').addClass('pudu')

# vars

current_url = "" + window.location.href

# page

pages =
  thread: current_url.indexOf('.com/thread/') != -1

# $ele

$ele =
  controlBar: $('.posts > .control-bar')
  postHeader: $('.posts .content-head')


# watcher
# [we need watcher because some function in this forum using ajax to update]

watcher = {}
watcher_loop = ->
  for name, func of watcher
    func() # exec each watcher
  setTimeout watcher_loop, 1000 # repeat
watcher_loop() # start watcher

# ========== THREAD ========= #

if pages.thread

  #=== add pagination to bottom ===#

  watcher['add_thread_pagination'] = ->

    page = $ele.controlBar.find('.state-selected').text() # page number

    # updated ?
    if $ele.controlBar.data('page') != page

      # clone pagination
      $ctb = $ele.controlBar.clone()
      $ctb.find('> div').remove() # remove all eles except pagination

      # wrap with div to prevent js selector
      ctbHtml = '<div class="control-bar ui-helper-clearfix pudu-thread-pagination" style="text-align: center"><div>' + $ctb.html() + '</div></div>'

      $('.pudu-thread-pagination').remove() # remove old if exist
      $('.posts > .content').after ctbHtml

      # save current page number
      $ele.controlBar.data 'page', page

  #=== add focus to liked comment ===#

  watcher['add_focus_to_comment'] = ->

    # each comment
    $('.posts .content-head').each ->

      if not $(@).data('done')

        # have like
        if $('.likes a', @).size() > 0

          # like < 10
          if $('.view-likes', @).size() == 0
            focus = 1
          else
            score = 2 + parseInt $('.view-likes', @).text().replace([' more', ','], '')
            if score < 10
              focus = 2
            else if score < 20
              focus = 3
            else if score < 30
              focus = 4
            else if score < 40
              focus = 5

          # add focus to post
          $(@).parents('article').addClass('focus-'+focus)

          # fix margin
          $(@).parent().find('.message').css 'margin': 0, 'minHeight': 350

        # mark as done
        $(@).data 'done', true
