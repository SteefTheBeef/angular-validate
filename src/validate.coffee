angular.module('slick-angular-validation', ['slick-angular-validation.rules', 'slick-angular-validation.factory'])

.directive 'validate', (
  $timeout
  $parse
  validationElementFactory
  accepted
  alpha
  alphaDash
  alphaNumeric
  boolean
  inString
  date
  different
  email
  match
  max
  maxDate
  maxLength
  min
  minDate
  minLength
  number
  regex
  required
  requiredIf) ->

  {
    restrict: 'A',
    require: ['ngModel', '^form'],
    compile: (element, attrs) ->
      unless attrs.name
        throw 'missing attribute name'

      validation = validationElementFactory.create(element, attrs)

      return (scope, element, attrs, ctrls) ->
        modelCtrl = ctrls[0]
        formCtrl = ctrls[1]

        $timeout () ->
          watchEquality = () ->
            for attribute in validation.attributes
              if attribute.key is 'match'
                scope.$watch attribute.value, () =>
                  $timeout () =>
                    modelCtrl.$setDirty()
                    run([attribute])

              if attribute.key is 'different'
                scope.$watch attribute.value, () =>
                  $timeout () =>
                    modelCtrl.$setDirty()
                    run([attribute])

              if attribute.key is 'minDate'
                scope.$watch attribute.value, () =>
                  $timeout () =>
                    modelCtrl.$setDirty()
                    run([attribute])

              if attribute.key is 'maxDate'
                scope.$watch attribute.value, () =>
                  $timeout () =>
                    modelCtrl.$setDirty()
                    run([attribute])

              if attribute.key is 'requiredIf'
                scope.$watch attribute.value, () =>
                  $timeout () =>
                    modelCtrl.$setDirty()
                    run([attribute])

          watchSubmit = () ->
            unless formCtrl and formCtrl.$name then return
            scope.$watch formCtrl.$name + '.$submitted', (value) ->
              if value is true
                modelCtrl.$setDirty()
                run()

          watchModel = () ->
            validationCount = 0
            scope.$watch attrs.ngModel, () ->
              if validationCount > 0
                run()
              validationCount++

          toggleItem = (validationKey, display) ->
            validation.element.children('.' + modelCtrl.$name + '-error-' + validationKey).css('display', display)

          toggleElement = (validationKey, isValid) ->
            if modelCtrl.$pristine then return
            unless isValid
              validation.element.css('display', 'block')
              toggleItem(validationKey, 'list-item')
            else
              toggleItem(validationKey, 'none')

          setIsValid = (key, isValid) ->
            modelCtrl.$setValidity(key, isValid)

          getModelValue = () ->
            #Allow the value to be set to false
            if modelCtrl.$modelValue is false or modelCtrl.$modelValue
              return $.trim(modelCtrl.$modelValue.toString())
            return ""

          getParsedValue = (value) ->
            val = $parse(value)(scope)
            unless val then return value
            val

          run = (specificValidationAttributes) ->
            modelValue = getModelValue()
            for attribute in (specificValidationAttributes || validation.attributes)
              result = null
              switch attribute.key
                when 'accepted' then result = accepted.validate(modelValue)
                when 'alpha' then result = alpha.validate(modelValue)
                when 'alphaDash' then result = alphaDash.validate(modelValue)
                when 'alphaNumeric' then result = alphaNumeric.validate(modelValue)
                when 'boolean' then result = boolean.validate(modelValue)
                when 'inString' then result = inString.validate(modelValue, $parse(attribute.value)(scope))
                when 'date' then result = date.validate(modelValue, attribute.value)
                when 'different' then result = different.validate(modelValue, $parse(attribute.value)(scope))
                when 'email' then result = email.validate(modelValue)
                when 'match' then result = match.validate(modelValue, $parse(attribute.value)(scope))
                when 'max' then result = max.validate(modelValue, attribute.value)
                when 'maxLength' then result = maxLength.validate(modelValue, attribute.value)
                when 'min' then result = min.validate(modelValue, attribute.value)
                when 'maxDate' then result = maxDate.validate(modelValue, $parse(attribute.value)(scope))
                when 'minDate' then result = minDate.validate(modelValue, $parse(attribute.value)(scope))
                when 'minLength' then result = minLength.validate(modelValue, attribute.value)
                when 'number' then result = number.validate(modelValue)
                when 'regex' then result = regex.validate(modelValue, attribute.value)
                when 'required' then result = required.validate(modelValue)
                when 'requiredIf'
                  result = requiredIf.validate(modelValue, $parse(attribute.value)(scope), getParsedValue(attribute.value2))
              setIsValid(attribute.key, result)
              toggleElement(attribute.key, result)

          watchSubmit()
          watchModel()
          watchEquality()

          element.blur () -> run()

          if attrs.type and (attrs.type is 'checkbox' or attrs.type is 'radio')
            element.change () -> run()

          run()
  }