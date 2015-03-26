angular.module('slick-angular-validation')
.factory 'minlength', (valueHelper) ->
  {
    link: (scope, ctrl, minlength) ->
      isModel = valueHelper.isModel(minlength)
      ctrl.$validators.minlength = (modelValue, viewValue) ->
        if ctrl.$isEmpty(modelValue) then return true

        minlen = valueHelper.getValue(scope, isModel, minlength)
        return viewValue.length >= parseInt(minlen)

      if isModel
        return scope.$watch minlength, () -> ctrl.$validate()
  }