import requests
import os
import loft_hvac

client_id = None
client_secret = None
redirect_uri = None


def auth():

    global client_id
    global redirect_uri

    if os.getenv('ENVIRONMENT') == 'dev':
        provider = 'virtualbox'
        bucket = None
    elif os.getenv('ENVIRONMENT') == 'stage':
        provider = 'aws'
        bucket = os.getenv('STAGE_AWS_S3_BUCKET')
    elif os.getenv('ENVIRONMENT') == 'prod':
        provider = 'aws'
        bucket = os.getenv('PROD_AWS_S3_BUCKET')

    if client_id is None:
        client_id = loft_hvac.read_secret(
            provider=provider,
            bucket=bucket,
            path='secret/meetup/key'
        )

    if redirect_uri is None:
        redirect_uri = loft_hvac.read_secret(
            provider=provider,
            bucket=bucket,
            path='secret/meetup/redirect_uri'
        )

    with requests.Session() as session:
        parameters = {}
        parameters['client_id'] = client_id
        parameters['response_type'] = 'code'
        parameters['redirect_uri'] = redirect_uri

        response = session.get(
            url="https://secure.meetup.com/oauth2/authorize",
            params=parameters
        )

        return(response.content)


def get_token(code=None):

    global client_id
    global client_secret
    global redirect_uri

    if os.getenv('ENVIRONMENT') == 'dev':
        provider = 'virtualbox'
        bucket = None
    elif os.getenv('ENVIRONMENT') == 'stage':
        provider = 'aws'
        bucket = os.getenv('STAGE_AWS_S3_BUCKET')
    elif os.getenv('ENVIRONMENT') == 'prod':
        provider = 'aws'
        bucket = os.getenv('PROD_AWS_S3_BUCKET')

    if client_id is None:
        client_id = loft_hvac.read_secret(
            provider=provider,
            bucket=bucket,
            path='secret/meetup/key'
        )

    if client_secret is None:
        client_secret = loft_hvac.read_secret(
            provider=provider,
            bucket=bucket,
            path='secret/meetup/secret'
        )

    if redirect_uri is None:
        redirect_uri = loft_hvac.read_secret(
            provider=provider,
            bucket=bucket,
            path='secret/meetup/redirect_uri'
        )

    with requests.Session() as session:
        parameters = {}
        parameters['client_id'] = client_id
        parameters['client_secret'] = client_secret
        parameters['grant_type'] = 'anonymous_code'
        parameters['redirect_uri'] = redirect_uri
        parameters['code'] = code

        response = session.post(
            url="https://secure.meetup.com/oauth2/access",
            params=parameters
        )

        return(response.json()['access_token'])
