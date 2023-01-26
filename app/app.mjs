export const handler = async(event) => {
    const response = {
        statusCode: 200,
        body: JSON.stringify('Hello from Lambda! v0.0.1'),
    };
    return response;
};