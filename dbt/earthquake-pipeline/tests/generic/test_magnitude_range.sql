{% test valid_magnitude_range(model, column_name) %}

    select *
    from {{ model }}
    where {{ column_name }} < -1.0 OR {{ column_name }} > 10

{% endtest %}