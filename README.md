# Tyrant

_"Freedom choked in dread we live, since tyrant was enthroned."_

Tyrant implements all common steps of authorization workflows using overridable _operations_. It allows a quick setup of sign in, sign up, change password, reset password, etc. Tyrant works well in Rails, but plays well with any Ruby environment.

Operations are provided for the following steps.

* SignIn
  * Confirmed
  * Hammer protection (3x wrong blabla)
  * Sticky (Remember me)
* SignUp
* SignOut
* ChangePassword
* ResetPassword
* Mutiple sessions with scopes

## Operations

TRB2 instead of pushing into controller


Tyrant exposes its public API using operations.

Operations are the pivotal element in the [Trailblazer architecture](https://github.com/apotonick/trailblazer). When it comes to customization, Tyrant doesn't rely on a "hopefully complete" configuration language as Devise does it.

Tyrant allows you to customise with Ruby. You can override entire workflow steps (operations), forms and validations (contracts) or methods using simple object-orientation and a clean API.


This means you can easily use them in Rails controllers.

```ruby
class SessionController < ApplicationController
  def sign_in
    run Tyrant::SignIn
  end
```

You can also run the public API in any other Ruby environment, e.g. a console or a Roda action.

```ruby
Tyrant::SignIn.({params})
```

Tyrant provides forms for all workflow steps. using [Reform](https://github.com/apotonick/reform) objects that are embedded into the operations.


=> Customise with inheritance, or override. Or just don't use the operation and write your own "step".

### Change Password

Tyrant provides a build-in form to change the password, which means that getting and validation the inputs is already done here.
Here what your `UserController` would look like (the `render` can be much better that than it just depends on what you need):

**To present the form (Build the `Tyrant::Contract::ChangePassword`)**
```ruby
def get_new_password
  run Tyrant::GetNewPassword
  render cell(Tyrant::Cell::ChangePassword, result["contract.default"], context: {"current_user" => User}, layout: Your::Cell::Layout)
end
```
Which will show a form with 4 inputs: `email`, `password`, `new_password`, `confirm_new_password` and a `Change Password` button.
 
**To evaluate the form (Build/Validate the `Tyrant::Contract::ChangePassword`, `policy` check, `change` password)**
```ruby
def change_password
  run Tyrant::ChangePassword do
    flash[:alert] = "The new password has been saved" #flash message
    return redirect_to user_path(tyrant.current_user)
  end

  render cell(Tyrant::Cell::ChangePassword, result["contract.default"], context: {"current_user" => User}, layout: Your::Cell::Layout)
end
```

Here the validation for the `Contract`:

* all the input are filled
* a User with that `email` exists
* the `password` is correct
* the `new_password` is different than `password`
* the `confirm_new_password` matches `new_password`

In case there is a problem in the inputs an error message is shown otherwise the `TRB::Op` will check the `policy`: the email in the form must be equal the email in `current_user`. The operation will return a falsey policy if not satisfied and it can be handled in different way, for example: 

```ruby
require 'reform/form/dry' 

class User::ChangePassword < Trailblazer::Operation
  step Nested(Tyrant::ChangePassword)
  failure :raise_error!
  step :notify!

  def raise_error!(options, *)
    raise ApplicationController::NotAuthorizedError if options["result.policy.default"].failure?
  end

  def notify!(options, current_user:, **)
    Notification::User.({}, "email" => current_user.email, "type" => "change_password")
  end

end
```
After nesting`Tyrant::ChangePassword` you can create a failure step where in case of a false policy a `NotAuthorizedError` is raised.

If `validation` and `policy` are satisfied the `new_password` is saved in the User model.

### Reset Password

There is a build-in form to reset the password as well. Here the actions in your controller:

**Present the form (Build the `Tyrant::Contract::GetEmail`)**
```ruby
def get_email
    run Tyrant::GetEmail
    render cell(Tyrant::Cell::ResetPassword, result["contract.default"], context: {"current_user" => User}, layout: Your::Cell::Layout)
end
```
Which will show a form with `email` and a `Reset Password` button.

**Evaluate the form (Build/Validate the `Tyrant::Contract::GetEmail`, generate a random password, update the model and sent an email notification)**
```ruby
def Tyrant::ResetPassword do 
    flash[:alert] = "Your password has been reset" #flash message
    return redirect_to "/sessions/new"
  end

  render cell(Tyrant::Cell::ResetPassword, result["contract.default"], context: {"current_user" => User}, layout: Your::Cell::Layout)
end
```

The contract validation will check if the email is filled and if a the user exists in your database.
In case the validation is satisfied a random 8 characters password is generated and a basic notification email is sent to the User's email.

To change how to generate a new password and the email notification creating your own operation [inherithing](http://trailblazer.to/gems/operation/2.0/api.html#inheritance-override) it from `Tyrant::ResetPassword` and override the `:generate_password!` and `:notify_user!` steps.
Example:

```ruby
require 'reform/form/dry' 

class User::ResetPassword < Tyrant::ResetPassword
  step :generate_password!, override: true
  step :notify_user!, override: true

  def generate_password!(options, *)
    options["new_password"] = "NewPassword"
  end

  def notify_user!(options, current_user:, **)
    #my notification
    true
  end

end
```
In this way my new password will be always `NewPassword` and I don't send any notification.

The build-in email notification is sent using [Pony](https://github.com/benprew/pony) gem.
Replace the step or override `email_options!` to set your options and test your code:
```ruby
Tyrant::Mailer.class_eval do 
  def email_options!(options, *)
    Pony.options = {via: :test}
  end  
end
```

This may be used as `Forgot Password` as well.

*To use custom `view` files save your file in the folder `app/concepts/tyrant/view` with names `change_password.slim` and `reset_password.slim`.*

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'tyrant'
```

## Rails

Tyrant comes with a railtie to provide you an initializer. In Rails, add this to an initializer.

```ruby
require "tyrant/railtie"
```

The forms are presented using formular and bootstrap so this needs to be into an initializer.

```ruby
Formular::Helper.builder= :bootstrap4
```

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).