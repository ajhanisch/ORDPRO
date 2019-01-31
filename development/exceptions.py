class Error(Exception):
    ''' Base class for other exceptions '''
    pass

class OrdersDoNotExistError(Error):
    ''' Raised when AfcosMonitor _check_orders_directory finds no order files in input directory and _count_current_orders comes back with no orders '''
    pass

class OrdersNumberPatternError(Error):
    ''' Raised when AfcosMonitor _get_current_orders_number is unable to match set order number pattern '''
    pass

class OrdersNumberEqualError(Error):
    ''' Raised when AfcosMonitor _compare_orders_numbers determines current and previous run of orders is the same '''
    pass

class MissingRequiredOrdersFilesError(Error):
    ''' Raised when AfcosMonitor _gather_current_orders_files is unable to gather all (4) required files in input directory '''
    pass

class VariableValidationError(Error):
    ''' Raised when AfcosParser _validate_variables is unable to match captured variables with required regex pattern '''
    pass

class InvalidHostError(Error):
    ''' Raised when ElasticsearchManager _validate_host determines the host value given is not a proper IP address '''
    pass

class InvalidPortError(Error):
    ''' Raised when ElasticsearchManager _validate_port determines the port value given is not a proper port number '''
    pass

class UnableToReachElasticsearchHostError(Error):
    ''' Raised when ElasticsearchManager _validate_host_connection is unable to get a return code status of 200 (host is up and responding) from given host and port '''
    pass

class UnexpectedResultCreatingIndexError(Error):
    ''' Raised when ElasticsearchManager _create_index receives an uknown/incorrect reponse when creating desired index '''
    pass

class FailedToAddDataToElasticsearchIndexError(Error):
    ''' Raised when ElasticsearchManager _add_data does not get a created response from Elasticseach API '''
    pass

class NoConfigFileActionSpecified(Error):
    ''' Raised when configuration file actions section is missing a True value for both create_orders_in_elasticsearch and create_orders_in_output_directory. At least one must be set to True. '''
    pass
