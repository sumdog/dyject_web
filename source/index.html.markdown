
About
=====

Dyject is a dependency injection module  for Python. Unlike other *enterprise* libraries use for Inversion of Control (IoC) that have classes which look like `AbstractSingletonProxyFactoryBean`, dyject is simple to understand and easy to use. It supports both Python 2.7 and Python 3, has no other dependencies and uses standard configuration files to define and wire objects. 

<a href="https://twitter.com/dyject" class="twitter-follow-button" data-show-count="false">Follow @dyject</a>
<script>!function(d,s,id){var js,fjs=d.getElementsByTagName(s)[0],p=/^http:/.test(d.location)?'http':'https';if(!d.getElementById(id)){js=d.createElement(s);js.id=id;js.src=p+'://platform.twitter.com/widgets.js';fjs.parentNode.insertBefore(js,fjs);}}(document, 'script', 'twitter-wjs');</script>


Installation
============

The dyject module can be installed using `easy_install`.

<pre class="sh_sourceCode sh_sh">
easy_install dyject
</pre>

Alternatively, the latest version of dyject can be [downloaded](https://pypi.python.org/pypi?:action=display&name=dyject) from the Python Package Index and installed using `setup.py`

<pre class="sh_sourceCode sh_sh">
tar xvfz dyject-0.7.2.tar.gz
cd dyject-0.7.2
sudo python setup.py install
</pre>


Configuration
=============

The following is a sample configuration file:

<pre class="sh_desktop sh_sourceCode">
[ConfigurationHandler]
class = examples.classes.ConfigurationHandler
system = 'linux'
version = 1.0
supported_versions = [ 0.2 , 0.3, 0.5 , 0.8 , 1.0 ]
default_config = class-ref\ClientConfig
configs = class-ref\{ServiceConfig,ClientConfig,OtherConfig}

[BaseConfig]
class = examples.classes.BaseConfig
config_type = 'BASE'
arch = 'x86_64'

[ServiceConfig]
inherit = BaseConfig
config_type = 'SERVICE'
process = '/usr/bin/service -d'

[ClientConfig]
inherit = BaseConfig
config_type = 'CLIENT'
process = '/usr/bin/client -d'

[OtherConfig]
inherit = BaseConfig
class = examples.classes.OtherConfig
config_type = 'SPECIAL'
process = 'cifs://remote_host/share1/other.bin'
arch = 'arm'
</pre> 


In the above example, each configuration section corresponds to name for identifying an instance of a class. This name is what will be used within the Python code to retrieve an object. Within each section, there must be either a `class` or `inherit` attribute (or both) defined. `class` must be a full path to a Python class. `inherit` must specify the name of another configuration section. If no `class` is defined, dyject will look up the class reference in `inherit` to determine which class to use. It will continue up the inheritence tree defined in the configuration file until a `class` attribute is found.

All other attributes are assigned as class members. The right side of the equal sign is interpreted based on standard Python typing . Therefore, in the `ConfigurationHandler` example, `system` will be set as a string, `version` will be a float, `supported_versions` will be set as a list and so fourth. 

If a value starts with `class-ref\`, the value given must be the name of another class as defined by its section heading. Braces can be used to define lists of objects. All objects set using `class-ref` are singletons. Therefore, in the above example, the same `ClientConfig` class will be set to both the `default_config` property and the second element in the `configs` list.

To recap, configuration elements are defined as follows:

<table> 
  <tr>
    <td>[ClassIdentifier]</td>
    <td>Name by which a class is identified and referenced to</td>
  </tr>
  <tr>
    <td>class/inherit =</td>
    <td>Indicates the name of the module and class to use as the instance for the given object.
      If no name is given, <code>inherit</code> must be defined and a section within the inheritence tree must define <code>class</code>. If both <code>class</code> and <code>inherit</code> are defined, the <code>class</code> within the section will be used to create the object and attributes will be assigned bottom up from the inheritence tree. Only the top <code>class</code> attribute will be used to define the object and other <code>class</code> attributes from parents will be ignored. 
    </td>
  </tr>
  <tr>
    <td><i>attribute</i> =</td>
    <td>
      Class properties are assigned by attribute name. The value of the attribute determines the type using standard Python duck typing. <code>class-ref\</code> is used to indicate that a class references by section name in the configuration file should be set as the given property. Multiple objects can be set using braces to indicate a list of objects. 
    </td>
  </tr>
</table>

Usage
=====

With dependency injection, all the objects should have their dependencies set within the configuration file. This is sometimes referred to as _wiring_. Within a Python application, only one object should have to be called by name. This is sometimes known as the _bootstrapping object_. The following is an example of how to pull an instance of an object from a dyject configuration file:


<pre class="sh_python sh_sourceCode"> 
#!/usr/bin/env python

from dyject import Context

if __name__ == '__main__':

   ctx = Context()
   ctx.load_config('example.config')

   client = ctx.get_class('ClientConfig')
   config = ctx.get_class('ConfigurationHandler')

   print('Client arch is {0}'.format(client.arch))
   print('Configuration Handler config objects: {0}'.format(config.configs))

   other_a = ctx.get_class('OtherConfig',prototype=True)
   other_b = ctx.get_class('OtherConfig',prototype=True)

   if id(other_a) != id(other_b):
     print('Other objects are distinct instances')

</pre>

Notice that the `prototype` argument can be set when calling `get_class`. By default, `get_class` will return a singleton object. By setting `prototype` to `True`, a new instance of the requested object is created that is not stored in dyject's object cache. 


Source Code
===========

Both Source code and example for dyject can be found on Github. 

<table>
  <tr>
    <td><a href="https://github.com/sumdog/dyject">dyject</a></td>
    <td>The core dyject python module</td>
    <td rowspan="3" id="pycat_td"><img src="/images/pythocat.png" alt="Github Pythocat" id="pythocat"/></td>
  </tr>
  <tr>
    <td><a href="https://github.com/sumdog/dyject_examples">dyject_examples</a></td>
    <td>Source code for the examples listed on this page</td>
  </tr>
  <tr>
    <td><a href="https://github.com/sumdog/dyject_web">dyject_web</a></td>
    <td>The source code used by <a href="http://middlemanapp.com">Middleman</a> to generate this website</td>
  </tr>
</table>





Testing
=======

Unit tests can be found within the source code. Simply run the script `run_tests.py` and the following output should be generated. Although dyject has been tested with Python 2.7 and Python 3.2, running these tests should ensure that dyject runs sanely under older and newer version.

![Unit Tests Screenshot](/images/tests.png)


Limitations
===========

Although the name `class` is reserved and cannot be used as a class member name in Python, the name `inherit` is not. Because dyject uses this term as a keyword in is configuration, it cannot currently set a class member named `inherit`.

Currently dyject doesn't support constructor arguments. Classes that have constructors that take in more attributes than `self` without default values currently can not be handled using a dyject configuration file.

Inheritance within the configuration file does not necessarily correlate to inheritence within Python. It is possible to inherit from another configuration item which has a class that is not the current's parent. Attributes will be assigned bottom up with all `class` attributes being ignored except for the top one.


Issues
======

Please submit bugs to the [project's issue tracker](https://github.com/sumdog/dyject/issues) on Github.

License
=======

Dyject is licensed under the [Apache 2.0 License](http://www.apache.org/licenses/LICENSE-2.0). 

<img src="images/ASF-logo.svg" alt="Apache Foundation Logo" id="asf" />


