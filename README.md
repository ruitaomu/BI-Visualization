# BrainIntelligence

See `provision/README.md` for instructions to setup a server.

## Database

Create the database on the server:

    sudo su postgres
    createuser --create-db <user_name> # Same as login user
    exit
    createdb <database_name> # As configured in database.yml later

## Deployment

    mina setup # Edit files as instructed afterwards
    mina deploy

## Configuration

### Amazon S3

Create a bucket where the videos will be stored. Open the bucket's
CORS Configuration (Properties > Permissions) and add the following:

    <?xml version="1.0" encoding="UTF-8"?>
    <CORSConfiguration xmlns="http://s3.amazonaws.com/doc/2006-03-01/">
        <CORSRule>
            <AllowedOrigin>*</AllowedOrigin>
            <AllowedMethod>PUT</AllowedMethod>
            <AllowedMethod>POST</AllowedMethod>
            <AllowedMethod>DELETE</AllowedMethod>
            <AllowedMethod>GET</AllowedMethod>
            <ExposeHeader>ETag</ExposeHeader>
            <AllowedHeader>*</AllowedHeader>
        </CORSRule>
    </CORSConfiguration>

If using DreamObjects, just create a `cors.xml` file with the contents as above
and upload it to the root of the bucket.

