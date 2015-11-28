from pyapns import configure, provision, notify
configure({'HOST': 'http://localhost:7077/'})
provision('myapp', open('pushCerDev.pem').read(), 'sandbox')
notify('myapp', '46f256ae81f7961a3a74774a92e4ede77f965562b755abb4cfa83694f7295f97', {'aps':{'alert': 'nosmoking!!!'}})
