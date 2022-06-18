#!/usr/bin/env python

# Copyright: (c) 2018, Terry Jones <terry.jones@example.org>
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)
from __future__ import (absolute_import, division, print_function)
from ansible.module_utils.basic import AnsibleModule
__metaclass__ = type
import requests
import json

DOCUMENTATION = r'''
---
module: dynv6

short_description: Manipulate DNS records on dynv6.com

# If this is part of a collection, you need to use semantic versioning,
# i.e. the version is of the form "2.5.0" and not "2.4".
version_added: "0.1.0"

description: Ansible module to add and remove records on dynv6.com

options:
    name:
        description: This is the message to send to the test module.
        required: true
        type: str
    new:
        description:
            - Control to demo if the result of this module is changed or not.
            - Parameter description can be a list as well.
        required: false
        type: bool
# Specify this value according to your collection
# in format of namespace.collection.doc_fragment_name
extends_documentation_fragment:
    - my_namespace.my_collection.my_doc_fragment_name

author:
    - Your Name (@yourGitHubHandle)
'''

EXAMPLES = r'''
# Pass in a message
- name: Test with a message
  my_namespace.my_collection.my_test:
    name: hello world

# pass in a message and have changed true
- name: Test with a message and changed output
  my_namespace.my_collection.my_test:
    name: hello world
    new: true

# fail the module
- name: Test failure of the module
  my_namespace.my_collection.my_test:
    name: fail me
'''

RETURN = r'''
# These are examples of possible return values, and in general should use other names for return values.
original_message:
    description: The original name param that was passed in.
    type: str
    returned: always
    sample: 'hello world'
message:
    description: The output message that the test module generates.
    type: str
    returned: always
    sample: 'goodbye'
'''


def run_module():
    endpoint = 'https://dynv6.com/api/v2/'
    valid_states = ['present', 'absent']
    valid_types = ['A', 'AAAA', 'CAA', 'CNAME', 'MX', 'SPF', 'SRV', 'TXT']


    class BearerAuth(requests.auth.AuthBase):
        def __init__(self, token):
            self.token = token

        def __call__(self, r):
            r.headers["authorization"] = "Bearer " + self.token
            r.headers["Content-Type"] = "application/json"
            return r
    def recordEquals(record1 , record2):
        record1['name'] = record1['name'].replace("@","")
        record2['name'] = record2['name'].replace("@","")
        #if both record have the zoneID field compare it if not skip it
        if ('zoneID' in record1 and 'zoneID' in record2 ) and record1['zoneID'] != record2['zoneID']:
            return False
        if (record1['name'] != record2['name']):
            return False
        if record1['type'] != record2['type']:
            return False
        if record1['data'] != record2['data']:
            return False
        if record1['type'] == 'MX' or record1['type'] == 'SRV':
            if record1['priority'] != record2['priority']:
                return False
        if  record1['type'] == 'SRV':
            if record1['port'] != record2['port']:
                return False
            if record1['weight'] != record2['weight']:
                return False
        if  record1['type'] == 'CAA':
            if record1['flags'] != record2['flags']:
                return False
            if record1['tag'] != record2['tag']:
                return False
        return True

    def recordCreate():
        data = {}
        data['name'] = module.params['record']
        data['type'] = module.params['type']
        data['data'] = module.params['data']
        if data['type'] == 'MX' or data['type'] == 'SRV':
            data['priority'] = module.params['priority']
        else:
            data['priority'] = 0

        if data['type'] == 'SRV':
            data['port'] = module.params['port']
            data['weight'] = module.params['weight']
        else:
            data['port'] = 0
            data['weight'] = 0

        if data['type'] == 'CAA':
            data['flags'] = module.params['flags']
            data['tag'] = module.params['tag']
        else:
            data['flags'] = 0
            data['tag'] = ''

        return data



    # define available arguments/parameters a user can pass to the module
    module_args = dict(
        token=dict(type='str', required=True),
        record=dict(type='str', required=True),
        state=dict(type='str', required=False),
        type=dict(type='str', required=False),
        data=dict(type='str', required=False),
        priority=dict(type='int', required=False),
        port=dict(type='int', required=False),
        weight=dict(type='int', required=False),
        flags=dict(type='int', required=False),
        tag=dict(type='str', required=False),
    )

    # seed the result dict in the object
    # we primarily care about changed and state
    # changed is if this module effectively modified the target
    # state will include any data that you want your module to pass back
    # for consumption, for example, in a subsequent task
    result = dict(
        changed=False,
        original_message='',
        message=''
    )

    # the AnsibleModule object will be our abstraction working with Ansible
    # this includes instantiation, a couple of common attr would be the
    # args/params passed to the execution, as well as if the module
    # supports check mode
    module = AnsibleModule(
        argument_spec=module_args,
        supports_check_mode=True
    )
    # Check for valid parameters
        
    if ('state' in module.params and module.params['state'] is not None and module.params['state'] not in valid_states):
        module.fail_json(msg="Invalid state " + str(module.params['state']) + ". Valid are: " + ", ".join(valid_states) , **result)
    # if state = present then a valid type needs to be specified
    if (module.params['state'] is None or module.params['state'] == 'present'):
        if (module.params['type'] != '' and module.params['type'] not in valid_types):
            module.fail_json(msg='Invalid type. Valid are: ' + ", ".join(valid_types), **result)
        if(module.params['data'] == ''):
            module.fail_json(msg='Empty data is not allow when creating a record', **result)


    # if the user is working with this module in only check mode we do not
    # want to make any changes to the environment, just return the current
    # state with no modifications
    if module.check_mode:
        module.exit_json(**result)

    # manipulate or modify the state as needed (this is going to be the
    # part where your module will do what it needs to do)

    response = requests.get(endpoint + 'zones', auth=BearerAuth(module.params['token']))
    if (response.status_code == 401):
        module.fail_json(msg='Unauthorized check your Token', **result)

    if (module.params['record'] != ''):
        # if record is set find corresponding zone
        jsonzones = response.json()
        for jsonzone in jsonzones:
            if (jsonzone['name'] in module.params['record']):
                zone_id = jsonzone['id']
                #Since dynv6 wants the record name to be without the zone name, we remove it
                module.params['record'] = module.params['record'].replace('.' + jsonzone['name'],'')
                break
        #check if the record exists
        r = requests.get(endpoint + 'zones/' + str(zone_id)+ '/records', auth=BearerAuth(module.params['token']))
        module.debug(r.text)
        target = recordCreate()
        recordExists = False
        for record in r.json():
            #raise Exception(str(record))
            if recordEquals(target, record):
                recordExists = True
                record_id = record['id']
                break

        if module.params['state'] == 'absent':
            if recordExists:
                 #remove record
                r = requests.delete(endpoint + 'zones/' + str(zone_id)+ '/records/' + str(record_id), auth=BearerAuth(module.params['token']))
                if r.status_code == 204:
                    result['changed'] = True
                else:
                    module.fail_json(msg='An error occured while deleting record ' + str(r.status_code), **result)
            else:
                result['changed'] = False
        elif module.params['state'] == 'present' or module.params['state'] is None:
            if recordExists:
                result['changed'] = False
            else:
                #create record
                r = requests.post(endpoint + 'zones/' + str(zone_id)+ '/records' , auth=BearerAuth(module.params['token']), data=json.dumps(target))
                if r.status_code == 200:
                    result['changed'] = True
                else:
                    module.fail_json(msg='An error occured while creating record ' + str(r.status_code) + ' ' + json.dumps(target), **result)








    # use whatever logic you need to determine whether or not this module
    # made any modifications to your target
    #if module.params['new']:
    #    result['changed'] = True

    # during the execution of the module, if there is an exception or a
    # conditional state that effectively causes a failure, run
    # AnsibleModule.fail_json() to pass in the message and the result
    #if module.params['name'] == 'fail me':
    #    module.fail_json(msg='You requested this to fail', **result)

    # in the event of a successful module execution, you will want to
    # simple AnsibleModule.exit_json(), passing the key/value results
    module.exit_json(**result)


def main():
    run_module()


if __name__ == '__main__':
    main()
