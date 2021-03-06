#!/usr/bin/python

import time
import json
import jsonpath

import conf


def get_ne_info_list_from_db(ne_filter):
    with open(conf.NE_INFO_TABLE) as f_ne_info:
        ne_info_table = json.load(f_ne_info)

    if ne_info_table:
        ne_info_list = jsonpath.jsonpath(ne_info_table, ne_filter)
        return ne_info_list if ne_info_list else []
    else:
        return []


def get_ne_info_from_db_by_id(ne_id):
    ne_filter = '$..[?(@.nEIdentification == "%s")]' % ne_id

    ne_info_list = get_ne_info_list_from_db(ne_filter)

    return ne_info_list[0] if ne_info_list else None


def update_ne_info(ne_info):
    with open(conf.NE_INFO_TABLE) as f_ne_info:
        ne_info_table = json.load(f_ne_info)

    ne_info["updateTime"] = time.asctime()

    if ne_info_table:
        for i in range(0, len(ne_info_table)):
            if ne_info_table[i]["nEIdentification"] == ne_info["nEIdentification"]:
                ne_info_table[i] = ne_info
                break
        else:
            ne_info_table.append(ne_info)
    else:
        ne_info_table = [ne_info]

    with open(conf.NE_INFO_TABLE, 'w') as f_ne_info:
        json.dump(ne_info_table, f_ne_info, indent=2)


def send_notification(notification, process_id):
    notification_file = conf.NOTIFICATION_DIR + '/%s-%d' % (notification['notificationType'], process_id)

    with open(notification_file, 'w') as f_notification:
        f_notification.write(json.dumps(notification))
