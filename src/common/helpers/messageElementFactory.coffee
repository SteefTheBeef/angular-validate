angular.module('slick-angular-validation')
.factory 'messageContainerFactory', (SlickAngularValidation) ->
  findNameOfOtherField = (element, itemValue) ->
    form = element.parents('form').first()
    unless form.length then return false

    field = form.find('*[ng-model="' + itemValue + '"]').first()
    unless field.length then return false
    field.attr('name')

  getMessage = (item, element) ->
    if item.customMessage then return item.customMessage

    messageObj = SlickAngularValidation.getMessage(item.key)
    messageObj.message.replace('#argument', item.value)
  {
    beginContainer: (formCtrlName, modelCtrlName) ->
      '<ul ng-messages="' + formCtrlName + '.'+ modelCtrlName + '.$error" class="slick-angular-validation-messages">'

    createMessageFromItem: (item, element) ->
      '<li ng-message="' + item.key + '">' + getMessage(item, element) + '</li>'

    endContainer: () ->
      '</ul>'
  }