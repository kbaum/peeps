## Goal

Prototype the ability to define namespaced json apis that uses a namespaced pundit policy.

https://github.com/kbaum/peeps

Which is a continuation of this project:

https://github.com/cerebris/peeps

## Namespaced JSON APIS

### Reference Pundit Policy within Our Resources

In order to create a namespaced resource for a `PhoneNumber` resource under the namespace `Bar`, we need to create namespaced route entry in our routes file:

```ruby
namespace :bar do
  jsonapi_resources :phone_numbers
end
```

An empty controller that inhertis from ApplicationController which must include `JSONAPI::ActsAsResourceController`

```ruby
module Bar
  class PhoneNumbersController < ApplicationController
  end
end
```

And add a namedspace `Bar::PhoneNumber` which defines the model_name.

```ruby
module Bar
  class PhoneNumberResource < ApplicationResource
    model_name 'PhoneNumber'
    attributes :name, :phone_number
  end
end
```

### Association

Within a namespace resource, any association must point to a resource that exists within the namespace. In our example, we want to add `has_one` Contact.

```ruby
module Bar
  class PhoneNumberResource < ApplicationResource
    model_name 'PhoneNumber'
    attributes :name, :phone_number
    has_one :contact
  end
end
```

The contact resource needs to exist within the Bar namespace. Because we have a `ContactResource` defined in the root namespace, we can inherit from that:

```ruby
module Bar 
  class ContactResource < ::ContactResource
  end
end
```

And our ::ContactResource looks like:

```ruby
class ContactResource < ApplicationResource
  attributes :name_first, :name_last, :email, :twitter
  has_many :phone_numbers, class_name: "PhoneNumber"
end
```

## Namespaced Pundit Policies

This section describes two approaches. In the first approach we hook into pundit ourselves. The second approach briefly describes what we do today with jsonapi-authorization.

### Hooking Directory Into Pundit Ourselves

For this example, we will have one policy for PhoneNumber and another for Bar::PhoneNumber. First define the two policies:

```ruby
class PhoneNumberPolicy
  def initialize(user, phone_number)
    @user = user
    @phone_number = phone_number
  end

  def create?
    true
  end
end

module Bar
  class PhoneNumberPolicy
    def initialize(user, phone_number)
      @user = user
      @phone_number = phone_number
    end

    def create?
      false
    end
  end
end
```

Notice `PhoneNumberPolicy` permits create but `Bar::PhonNumberPolicy`` does not. Next reference the policy within the resource:

```ruby
class PhoneNumberResource < ApplicationResource
  include Pundit

  before_create { authorize(_model, :create?) }

  attributes :name, :phone_number
  has_one :contact

  filter :contact
end

module Bar
  class PhoneNumberResource < ApplicationResource
    include Pundit
    before_create { authorize(_model, :create?, policy_class: Bar::PhoneNumberPolicy) }

    model_name 'PhoneNumber'
    attributes :name, :phone_number
    has_one :contact

    filter :contact
  end
end
```

Notice the ```Bar::PhoneNumberResource``` explicitly references the policy. We can create a phone_number for the root namespace:

```
curl -i -H "Accept: application/vnd.api+json" -H 'Content-Type:application/vnd.api+json' -X POST -d '{ "data": { "type": "phone-numbers", "relationships": { "contact": { "data": { "type": "contacts", "id": "1" } } }, "attributes": { "name": "home", "phone-number": "(603) 555-1212" } } }' http://localhost:3000/phone-numbers
```
We cannot for the bar namespace:

```
curl -i -H "Accept: application/vnd.api+json" -H 'Content-Type:application/vnd.api+json' -X POST -d '{ "data": { "type": "phone-numbers", "relationships": { "contact": { "data": { "type": "contacts", "id": "1" } } }, "attributes": { "name": "home", "phone-number": "(603) 555-1212" } } }' http://localhost:3000/bar/phone-numbers
```

### Using jsonapi-authorization custom authorizer

If we instead go with jsonapi-authorization, we can define a [custom authorizor](https://github.com/venuu/jsonapi-authorization#configuration). The jsonapi-authorization library comes with it's own [DefaultPunditAuthorizor](https://github.com/venuu/jsonapi-authorization/blob/master/lib/jsonapi/authorization/default_pundit_authorizer.rb) but it does not provide a way to customize the location of the pundity policy. As a result, in the current liftforward/api project, we define our own [authorizor](https://github.com/liftforward/api/blob/master/app/jsonapi/namespaced_pundit_authorizer.rb) which allows for picking a policy based on the resource's namespace. This policy seems to be a copy and paste of the default_pundity_authorizer with the added ability to have namespaced pundit policies.


