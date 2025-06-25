<?xml version="1.0" encoding="UTF-8"?>
<!--  ------------------------------------------------------------------
      tei-to-html.xsl  —  the ONE canonical transform for Folger plays
      ------------------------------------------------------------------
      • Reads TEI Simple (Folger) XML
      • Emits HTML5 with semantic classes only
      • Leaves all styling to CSS; leaves text untouched
      ------------------------------------------------------------------  -->
<xsl:stylesheet version="3.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    expand-text="yes">

  <!-- -----------------------------------------------------------------
       0.  Global settings
       ----------------------------------------------------------------- -->
  <xsl:output method="html" html-version="5"
              indent="yes" encoding="UTF-8"/>

  <!-- identity‑minus: copy nothing we don’t specify -->
  <xsl:mode on-no-match="shallow-skip"/>

  <!-- -----------------------------------------------------------------
       1.  Top‑level wrappers
       ----------------------------------------------------------------- -->
  <!-- whole play ------------------------------------------------------ -->
  <xsl:template match="tei:TEI">
    <article class="play">
      <xsl:apply-templates select="tei:text/tei:body/tei:div[@type='play']"/>
    </article>
  </xsl:template>

  <!-- act ------------------------------------------------------------- -->
  <xsl:template match="tei:div[@type='act']">
    <section class="act">
      <h2><xsl:value-of select="tei:head"/></h2>
      <xsl:apply-templates select="node()[not(self::tei:head)]"/>
    </section>
  </xsl:template>

  <!-- scene ----------------------------------------------------------- -->
  <xsl:template match="tei:div[@type='scene']">
    <section class="scene">
      <h3><xsl:value-of select="tei:head"/></h3>
      <xsl:apply-templates select="node()[not(self::tei:head)]"/>
    </section>
  </xsl:template>

  <!-- -----------------------------------------------------------------
       2.  Speech & stage business
       ----------------------------------------------------------------- -->
  <xsl:template match="tei:sp">
    <div class="sp">
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <xsl:template match="tei:speaker">
    <h4 class="speaker"><xsl:apply-templates/></h4>
  </xsl:template>

  <xsl:template match="tei:stage">
    <span class="stage"><xsl:apply-templates/></span>
  </xsl:template>

  <!-- -----------------------------------------------------------------
       3.  Lines & prose
       ----------------------------------------------------------------- -->
  <!-- verse line -->
  <xsl:template match="tei:l">
    <p class="line"><xsl:apply-templates/></p>
  </xsl:template>

  <!-- prose paragraph -->
  <xsl:template match="tei:p">
    <p class="para"><xsl:apply-templates/></p>
  </xsl:template>

  <!-- -----------------------------------------------------------------
       4.  Word‑level tokens (keep lexical metadata)
       ----------------------------------------------------------------- -->
  <xsl:template match="tei:w">
    <span class="w"
          data-lemma="{@lemma}"
          data-pos="{@pos}"
          data-orig="{@orig}"
          data-reg="{@reg}">
      <xsl:value-of select="."/>
    </span>
  </xsl:template>

  <xsl:template match="tei:pc">
    <span class="pc"><xsl:value-of select="."/></span>
  </xsl:template>

  <!-- explicit spaces -->
  <xsl:template match="tei:c[@type='space']">
    <xsl:text> </xsl:text>
  </xsl:template>

  <!-- -----------------------------------------------------------------
       5.  Pagination & line numbers (hidden unless shown by CSS)
       ----------------------------------------------------------------- -->
  <xsl:template match="tei:pb">
    <span class="pb" data-page="{@n}"></span>
  </xsl:template>

  <xsl:template match="tei:milestone[@unit='ftln']">
    <span class="ln" id="ftln{@n}"></span>
  </xsl:template>

</xsl:stylesheet>
