$(document).ready( ->
  $(document).on('click', '.file-upload-container', (e) ->
    e.preventDefault()
    $(this).parent().find('.real-file-input').click()
  )

  $(document).on('change', '.real-file-input', (e) ->
    filename = $(this).val().split(/\\/).pop()
    $(this).closest('div').find('.fake-file-input').html(filename)
  )
)

