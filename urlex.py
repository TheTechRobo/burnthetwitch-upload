import json_stream

import re

import sys
print(sys.argv[1], file=sys.stderr)

REGEX = re.compile(r"""(https?://[^\s<]+[^?~*|<>.,:;"'`)\]\s])""")

def extt(text: str):
    for match in re.finditer(REGEX, text, flags=0):
        start, finish = match.span()
        yield text[start:finish]

def parse_author(author):
    for url in extt(author['bio'] or ""):
        yield url
    for badge in author.get("badges", []):
        if badge['click_url']:
            yield badge['click_url']
        for icon in badge['icons']:
            yield icon['url']
    for image in author['images']:
        yield image['url']

def extract_urls(message):
    for url in parse_author(message['author']):
        yield url
    for url in extt(message['message']):
        yield url
    for emote in message.get("emotes", []):
        for image in emote['images']:
            yield image['url']

with open(sys.argv[1]) as file:
    messages = json_stream.load(file)
    for message in messages:
        for url in extract_urls(json_stream.to_standard_types(message)):
            print(url)
