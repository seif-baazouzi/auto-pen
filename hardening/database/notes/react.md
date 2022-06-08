### Source

[https://snyk.io/blog/10-react-security-best-practices/](https://snyk.io/blog/10-react-security-best-practices/)


### Default XSS protection with data binding

Use default data binding with curly braces {} and React will automatically escape values to protect against XSS attacks. Note that this protection only occurs when rendering textContent and not when rendering HTML attributes.

Use JSX data binding syntax {} to place data in your elements. 

Do this:

```
<div>{data}</div>
```

Avoid dynamic attribute values without custom validation.

Don’t do this:

```
<form action={data}>...
```


### Dangerous URLs

URLs can contain dynamic script content via javascript: protocol URLs. Use validation to assure your links are http: or https: to avoid javascript: URL based script injection. Achieve URL validation using a native URL parsing function then match the parsed protocol property to an allow list.

Do this:

```javascript
function validateURL(url) {
  const parsed = new URL(url)
  return ['https:', 'http:'].includes(parsed.protocol)
}

<a href={validateURL(url) ? url : ''}>Click here!</a>
```

Don’t do this:

```
<a href={attackerControlled}>Click here!</a>
```


### Rendering HTML

It is possible to insert HTML directly into rendered DOM nodes using dangerouslySetInnerHTML. Any content inserted this way must be sanitized beforehand.

Use a sanitization library like dompurify on any values before placing them into the dangerouslySetInnerHTML prop.

Use dompurify when inserting HTML into the DOM:

```javascript
import purify from "dompurify";
<div dangerouslySetInnerHTML={{ __html:purify.sanitize(data) }} />
```


### Direct DOM Access

Accessing the DOM to inject content into DOM nodes directly should be avoided. Use dangerouslySetInnerHTML if you must inject HTML and sanitize it before injecting it using dompurify.

Do this:

```javascript
import purify from "dompurify";
<div dangerouslySetInnerHTML={{__html:purify.sanitize(data) }} />
```

Avoid using refs and findDomNode() to access rendered DOM elements to directly inject content via innerHTML and similar properties or methods.

Don’t do this:

```javascript
this.myRef.current.innerHTML = attackerControlledValue;
```


### Server-side rendering

Data binding will provide automatic content escaping when using server-side rendering functions like ReactDOMServer.renderToString() and ReactDOMServer.renderToStaticMarkup().

Avoid concatenating strings onto the output of renderToStaticMarkup() before sending the strings to the client for hydration.

Don’t concatenate unsanitized data with the output of renderToStaticMarkup() to avoid XSS:

```javascript
app.get("/", function (req, res) {
  return res.send(
    ReactDOMServer.renderToStaticMarkup(
      React.createElement("h1", null, "Hello World!")
    ) + otherData
  );
});
```


### Known vulnerabilities in dependencies

Some versions of third-party components might contain JavaScript security issues. Check your dependencies and update when better versions become available.

Use a tool like the free Snyk CLI to check for vulnerabilities.

Automatically fix vulnerabilities with Snyk by integrating with your source code management system to receive automated fixes:

```
$ npx snyk test
```


### JSON state

It is common to send JSON data along with server-side rendered React pages. Always escape < characters with a benign value to avoid injection attacks.

Do escape HTML significant values from JSON with benign equivalent characters:

```javascript
window.__PRELOADED_STATE__ =   ${JSON.stringify(preloadedState).replace( /</g, '\\u003c')}
```


### Vulnerable versions of React

The React library has had a few high severity vulnerabilities in the past, so it is a good idea to stay up-to-date with the latest version.

Avoid vulnerable versions of the react and react-dom by verifying that you are on the latest version using npm outdated to see the latest versions.


### Linters

Install Linter configurations and plugins that will automatically detect security issues in your code and offer remediation advice.

Use the ESLint React security config to detect security issues in our code base.

Configure a pre-commit hook that fails when security-related Linter issues are detected using a library like husky.

Use Snyk to automatically update to new versions when vulnerabilities exist in the versions you are using.


### Dangerous library code

Library code is often used to perform dangerous operations like directly inserting HTML into the DOM. Review library code manually or with linters to detect unsafe usage of React’s security mechanisms.

Avoid libraries that do use dangerouslySetInnerHTML, innerHTML, unvalidated URLs or other unsafe patterns. Use security Linters on your node_modules folder to detect unsafe patterns in your library code.

