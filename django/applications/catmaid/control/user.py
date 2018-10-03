# -*- coding: utf-8 -*-

import json
import django.contrib.auth.views as django_auth_views
import six

from random import random

from guardian.utils import get_anonymous_user

from django.http import JsonResponse
from django.contrib.auth.decorators import user_passes_test
from django.contrib.auth.models import User

from catmaid.control.authentication import access_check


def not_anonymous(user):
    """Return true if the the user is neither Django's nor Guardian's anonymous
    user.
    """
    return user.is_authenticated and user != get_anonymous_user()

@user_passes_test(access_check)
def user_list(request):
    result = []
    for u in User.objects.all().select_related('userprofile') \
            .order_by('last_name', 'first_name'):
        up = u.userprofile
        result.append({
            "id": u.id,
            "login": u.username,
            "full_name": u.get_full_name(),
            "first_name": u.first_name,
            "last_name": u.last_name,
            "color": (up.color.r, up.color.g, up.color.b) })

    return JsonResponse(result, safe=False)

@user_passes_test(access_check)
def user_list_datatable(request):
    display_start = int(request.POST.get('iDisplayStart', 0))
    display_length = int(request.POST.get('iDisplayLength', -1))
    if display_length < 0:
        display_length = 2000  # Default number of result rows

    should_sort = request.POST.get('iSortCol_0', False)

    user_query = User.objects.all()

    # By default, there is no need to explicitly request a distinct result
    distinct = False

    # This field can be used to only return users that have used a certain
    # annotation.
    annotations = [v for k,v in six.iteritems(request.POST)
            if k.startswith('annotations[')]

    for annotation in annotations:
        user_query = user_query.filter(
                classinstanceclassinstance__relation__relation_name = \
                     'annotated_with',
                classinstanceclassinstance__class_instance_b__name = \
                     annotation)
        # Make sure we only get distinct user names
        distinct = True

    # The neuron_id field can be used to constrain the result by only showing
    # users that annotated a certain neuron.
    neuron_annotated = request.POST.get('neuron_id', None)
    if neuron_annotated:
        user_query = user_query.filter(
                classinstanceclassinstance__relation__relation_name = \
                     'annotated_with',
                classinstanceclassinstance__class_instance_a__id = \
                     neuron_annotated)
        # Make sure we only get distinct user names
        distinct = True

    if distinct:
        user_query = user_query.distinct()

    if should_sort:
        column_count = int(request.POST.get('iSortingCols', 0))
        sorting_directions = [request.POST.get('sSortDir_%d' % d, 'DESC')
                for d in range(column_count)]
        sorting_directions = map(lambda d: '-' if d.upper() == 'DESC' else '',
                sorting_directions)

        fields = ['username', 'first_name', 'last_name', 'id']
        sorting_index = [int(request.POST.get('iSortCol_%d' % d))
                for d in range(column_count)]
        sorting_cols = map(lambda i: fields[i], sorting_index)

        user_query = user_query.extra(order_by=[di + col for (di, col) in zip(
                sorting_directions, sorting_cols)])

    num_records = len(user_query)
    result = list(user_query[display_start:display_start + display_length])

    response = {
        'iTotalRecords': num_records,
        'iTotalDisplayRecords': num_records,
        'aaData': []
    }

    for user in result:
        response['aaData'] += [[
            user.username,
            user.first_name,
            user.last_name,
            user.id,
        ]]

    return JsonResponse(response)

@user_passes_test(access_check)
def update_user_profile(request):
    """ Allows users to update some of their user settings.

    If the request is done by the anonymous user, nothing is updated, but
    no error is raised.
    """
    # Ignore anonymous user
    if request.user == get_anonymous_user() or not request.user.is_authenticated:
        return JsonResponse({'success': "The user profile of the " +
                "anonymous user won't be updated"})

    for var in []:
        request_var = request.POST.get(var['name'], None)
        if request_var:
            request_var = var['parse'](request_var)
            # Set new user profile values
            setattr(request.user.userprofile, var['name'], request_var)

    # Save user profile
    request.user.userprofile.save()

    return JsonResponse({'success': 'Updated user profile'})

@user_passes_test(not_anonymous)
def change_password(request, **kwargs):
    return django_auth_views.password_change(request, **kwargs)
